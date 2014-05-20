#include "updater/updater.h"
#include <iostream>
#include <fstream>
#include <map>
#include <cstdio>
#include <cstdlib>
using namespace std;
#include <sys/stat.h>
#include <curl/curl.h>
#include <string.h>
// The way to download GitHub files are from
//https://raw.githubusercontent.com/bagder/curl/master/docs/examples/getinmemory.c
#include "cocos2d.h"

#ifdef WINDOWS
    #include <direct.h>
    #define RUNNING_DIR _getcwd
#else
    #include <unistd.h>
    #define RUNNING_DIR getcwd
#endif

namespace updater {
const int DIR_REVMARK = -1;
//https://help.github.com/articles/why-did-i-get-redirected-to-this-page
const string SERVER_ROOT
    = "https://raw.githubusercontent.com/Pisces000221/StayUnsweetened/master";

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
    ifstream f;
    f.open(dataFile);
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
    mkdir(filename.c_str(), 0777);
}

void removeFile(string filename)
{
    remove(filename.c_str());
}

void downloadFile(string onlineFile, string localFile)
{
  CCLOG("Downloading file %s to %s", onlineFile.c_str(), localFile.c_str());
  CURL *curl_handle;
  CURLcode res;

  struct MemoryStruct chunk;

  chunk.memory = (char *)malloc(1);  /* will be grown as needed by the realloc above */
  chunk.size = 0;    /* no data at this point */

  curl_global_init(CURL_GLOBAL_ALL);

  /* init the curl session */
  curl_handle = curl_easy_init();

  /* specify URL to get */
  curl_easy_setopt(curl_handle, CURLOPT_URL, onlineFile.c_str());

  /* send all data to this function  */
  curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);

  /* we pass our 'chunk' struct to the callback function */
  curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, (void *)&chunk);

  /* some servers don't like requests that are made without a user-agent
     field, so we provide one */
  curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, "libcurl-agent/1.0");

  /* get it! */
  res = curl_easy_perform(curl_handle);

  /* check for errors */
  if(res != CURLE_OK) {
    fprintf(stderr, "curl_easy_perform() failed: %s\n",
            curl_easy_strerror(res));
  }
  else {
    /*
     * Now, our chunk.memory points to a memory block that is chunk.size
     * bytes big and contains the remote file.
     *
     * Do something nice with it!
     */

    printf("%lu bytes retrieved\n", (long)chunk.size);
  }

  /* cleanup curl stuff */
  curl_easy_cleanup(curl_handle);

  //http://www.cplusplus.com/reference/ostream/ostream/write/
  ofstream file(localFile.c_str(), ios::binary);
  file.write(chunk.memory, chunk.size);
  file.close();

  if(chunk.memory)
    free(chunk.memory);

  /* we're done with libcurl, so clean it up */
  curl_global_cleanup();
}

void checkUpdate(string rootdir)
{
    CCLOG("Updater working under %s", rootdir.c_str());
    assetsData localData, onlineData;
    readAssetsData((rootdir + "/LOCAL_FILELIST").c_str(), localData);
    downloadFile(SERVER_ROOT + "/FILELIST", rootdir + "/ONLINE_FILELIST");
    readAssetsData((rootdir + "/ONLINE_FILELIST").c_str(), onlineData);
    ASSETS_DATA_MAP_ITERATE(localData.files)
        if (onlineData.files[i->first] == 0)
            removeFile(rootdir + i->first);
    ASSETS_DATA_MAP_ITERATE(localData.directories)
        if (onlineData.directories[i->first] == 0)
            removeDirectory(rootdir + i->first);
    cout << endl;
    ASSETS_DATA_MAP_ITERATE(onlineData.directories)
        if (localData.directories[i->first] == 0)
            createDirectory(rootdir + i->first);
    ASSETS_DATA_MAP_ITERATE(onlineData.files)
        if (localData.files[i->first] < i->second)
            downloadFile(SERVER_ROOT + i->first, rootdir + i->first);
}

}
