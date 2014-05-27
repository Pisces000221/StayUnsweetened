#include "updater/updater.h"
#include <iostream>
#include <fstream>
#include <map>
#include <thread>
#include <cstdio>
#include <cstdlib>
using namespace std;
#include <curl/curl.h>
#include <string.h>
// The way to download GitHub files are from
//https://raw.githubusercontent.com/bagder/curl/master/docs/examples/getinmemory.c
#include "cocos2d.h"
//#define WINDOWS

#ifdef WINDOWS
    #include <direct.h>
    #define RUNNING_DIR _getcwd
    #include <windows.h>
	#include <sys/stat.h>
#else
    #include <unistd.h>
    #define RUNNING_DIR getcwd
    #include <dirent.h>
    #include <sys/stat.h>
#endif

namespace updater {
const int DIR_REVMARK = -1;
//https://help.github.com/articles/why-did-i-get-redirected-to-this-page
const string SERVER_ROOT
    = "https://raw.githubusercontent.com/Pisces000221/StayUnsweetened/master";

bool _isFinished = false;
bool isFinished() { return _isFinished; }

struct MemoryStruct {
  char *memory;
  size_t size;
};

static size_t WriteMemoryCallback(void *contents, size_t size, size_t nmemb, void *userp)
{
  size_t realsize = size * nmemb;
  struct MemoryStruct *mem = (struct MemoryStruct *)userp;
  mem->memory = (char *)realloc(mem->memory, mem->size + realsize + 1);
  if(mem->memory == NULL) {
    /* out of memory! */
    printf("not enough memory (realloc returned NULL)\n");
    return 0;
  }
  memcpy(&(mem->memory[mem->size]), contents, realsize);
  mem->size += realsize;
  mem->memory[mem->size] = 0;
  return realsize;
}

void readAssetsData(const char *dataFile, assetsData &out)
{
    out.directories.clear();
    out.files.clear();
    ifstream f(dataFile);
    if (!f) return;
    while (!f.eof()) {
        int rev; string filename;
        f >> rev;
        f.ignore(1, ' ');
        getline(f, filename);
        if (filename != "")
            if (rev == DIR_REVMARK) out.directories[filename] = rev;
            else out.files[filename] = rev;
    }
    f.close();
}

void removeDirectory(string filename)
{
    rmdir(filename.c_str());
}

void createDirectory(string filename)
{
#ifdef WINDOWS
    CreateDirectoryA(filename.c_str(), 0);
#else
    mkdir(filename.c_str(), 0777);
#endif
}

void removeFile(string filename)
{
    remove(filename.c_str());
}

void downloadFile(string onlineFile, string localFile)
{
  _isFinished = false;
  std::thread t([=](){
  CCLOG("Downloading %s to %s", onlineFile.c_str(), localFile.c_str());
  CURL *curl_handle;
  CURLcode res;
  struct MemoryStruct chunk;
  chunk.memory = (char *)malloc(1);
  chunk.size = 0;
  curl_global_init(CURL_GLOBAL_ALL);
  curl_handle = curl_easy_init();
  curl_easy_setopt(curl_handle, CURLOPT_URL, onlineFile.c_str());
  curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
  curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, (void *)&chunk);
  curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, "libcurl-agent/1.0");
  res = curl_easy_perform(curl_handle);
  if(res != CURLE_OK)
    fprintf(stderr, "curl_easy_perform() failed: %s\n",
            curl_easy_strerror(res));
  curl_easy_cleanup(curl_handle);

  //http://www.cplusplus.com/reference/ostream/ostream/write/
  ofstream file(localFile.c_str(), ios::binary);
  file.write(chunk.memory, chunk.size);
  file.close();

  if(chunk.memory) free(chunk.memory);
  curl_global_cleanup();
  _isFinished = true;
  });
  //http://stackoverflow.com/questions/13999432/stdthread-terminate-called-without-an-active-exception-dont-want-to-joi
 t.detach();
}

void checkUpdate(string rootdir, std::function<void(float)> progressCallback)
{
    assetsData localData, onlineData;
    readAssetsData((rootdir + "/LOCAL_FILELIST").c_str(), localData);
    downloadFile(SERVER_ROOT + "/FILELIST", rootdir + "/ONLINE_FILELIST");
    readAssetsData((rootdir + "/ONLINE_FILELIST").c_str(), onlineData);
    // check all directories, build folder structure first
    ASSETS_DATA_MAP_ITERATE(localData.files)
        if (onlineData.files[i->first] == 0)
            removeFile(rootdir + i->first);
    ASSETS_DATA_MAP_ITERATE(localData.directories)
        if (onlineData.directories[i->first] == 0)
            removeDirectory(rootdir + i->first);
    // check all files
    ASSETS_DATA_MAP_ITERATE(onlineData.directories)
        if (localData.directories[i->first] == 0)
            createDirectory(rootdir + i->first);
    // count objects
    int download_ct = 0, download_tot = 0;
    ASSETS_DATA_MAP_ITERATE(onlineData.files)
        if (localData.files[i->first] < i->second) download_tot++;
    ASSETS_DATA_MAP_ITERATE(onlineData.files)
        if (localData.files[i->first] < i->second) {
            CCLOG("%s", (rootdir + i->first).c_str());
            downloadFile(SERVER_ROOT + i->first, rootdir + i->first);
            if (progressCallback != nullptr)
                progressCallback((float)(++download_ct) / (float)download_tot);
        }
    removeFile((rootdir + "/LOCAL_FILELIST").c_str());
    rename((rootdir + "/ONLINE_FILELIST").c_str(), (rootdir + "/LOCAL_FILELIST").c_str());
}

static size_t read_callback(void *ptr, size_t size, size_t nmemb, void *stream)
{
  curl_off_t nread;
  size_t retcode = fread(ptr, size, nmemb, (FILE *)stream);
  nread = (curl_off_t)retcode;
  return retcode;
}

void uploadFile(string localFile, string remoteServer, string onlineFile,
    string username, string password)
{
  _isFinished = false;
  std::thread t([=](){
  CURL *curl;
  CURLcode res;
  FILE *hd_src;
  struct stat file_info;
  curl_off_t fsize;

  string fullURL = remoteServer + onlineFile;

  /* get the file size of the local file */ 
  if(stat(localFile.c_str(), &file_info)) {
    printf("Couldnt open '%s': %s\n", localFile.c_str(), strerror(errno));
    return;
  }
  fsize = (curl_off_t)file_info.st_size;
  hd_src = fopen(localFile.c_str(), "rb");
  curl_global_init(CURL_GLOBAL_ALL);
  curl = curl_easy_init();
  if(curl) {
    curl_easy_setopt(curl, CURLOPT_USERPWD, (username + ":" + password).c_str());
    curl_easy_setopt(curl, CURLOPT_READFUNCTION, read_callback);
    curl_easy_setopt(curl, CURLOPT_UPLOAD, 1L);
    curl_easy_setopt(curl, CURLOPT_URL, fullURL.c_str());
    curl_easy_setopt(curl, CURLOPT_READDATA, hd_src);
    curl_easy_setopt(curl, CURLOPT_INFILESIZE_LARGE, (curl_off_t)fsize);
    curl_easy_setopt(curl, CURLOPT_FTP_CREATE_MISSING_DIRS, 1);
    res = curl_easy_perform(curl);
    if(res != CURLE_OK)
      fprintf(stderr, "curl_easy_perform() failed: %s\n",
              curl_easy_strerror(res));
    curl_easy_cleanup(curl);
  }
  fclose(hd_src);
  curl_global_cleanup();
  _isFinished = true;
 });
 t.detach();
}

}
