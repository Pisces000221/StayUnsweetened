#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void usage(char *prog_name)
{
    printf("Usage: %s <Input file> [<Output file> [<Width> <Height>]]\n", prog_name);
}

void trim(char *s)
{
    int len = strlen(s) - 1;
    while (s[len] == '\n' || s[len] == '\r' || s[len] == ' ') len--;
    s[len + 1] = 0;
}

int main_process(int argc, char **argv)
{
    char in_file[256], out_file[256];
    int width = -1, height = -1;
    if (argc == 1) {
        printf("Enter input file name: ");
        gets(in_file); trim(in_file);
        printf("Enter output file name (<Enter> for auto generate): ");
        gets(out_file); trim(out_file);
        if (strlen(out_file) == 0) {
            strcpy(out_file, in_file);
            int len = strlen(out_file);
            while (out_file[--len] != '.');
            out_file[len + 1] = 'p'; out_file[len + 2] = 'l';
            out_file[len + 3] = 'i'; out_file[len + 4] = 's';
            out_file[len + 5] = 't'; out_file[len + 6] = 0;
        }
        printf("Enter width, height (<Enter> for auto generate): ");
        char s[256]; gets(s);
        sscanf(s, "%d%d", &width, &height);
    } else if (argc == 2) {
        strcpy(in_file, argv[1]);
        strcpy(out_file, argv[1]);
        int len = strlen(out_file);
        while (out_file[--len] != '.');
        out_file[len + 1] = 'p'; out_file[len + 2] = 'l';
        out_file[len + 3] = 'i'; out_file[len + 4] = 's';
        out_file[len + 5] = 't'; out_file[len + 6] = 0;
        printf("Enter width, height (<Enter> for auto generate): ");
        char s[256]; gets(s);
        sscanf(s, "%d%d", &width, &height);
    } else if (argc == 3) {
        strcpy(in_file, argv[1]);
        strcpy(out_file, argv[2]);
        printf("Enter width, height (<Enter> for auto generate): ");
        char s[256]; gets(s);
        sscanf(s, "%d%d", &width, &height);
    } else if (argc == 5) {
        strcpy(in_file, argv[1]);
        strcpy(out_file, argv[2]);
        width = atoi(argv[3]); height = atoi(argv[4]);
    } else {
        usage(argv[0]);
        return 0;
    }

    printf("\nInput: %s\nOutput: %s\n", in_file, out_file);
    FILE *f_in, *f_out;
    f_in = fopen(in_file, "r");
    f_out = fopen(out_file, "w");
    if (!f_in || !f_out) {
        printf("\nERROR: Cannot open input/output file\n");
        return 10;
    }
    
    char s[256], frame_name[256];
    int img_x, img_y, img_width, img_height;
    /* Get XML and encoding info */
    fgets(s, 256, f_in); trim(s);
    fprintf(f_out, "%s\n", s);
    /* Read the next 2 lines */
    fgets(s, 256, f_in);
    fgets(s, 256, f_in);
    fprintf(f_out, "<!DOCTYPE plist PUBLIC \""
        "-//Apple Computer//DTD PLIST 1.0//EN\" "
        "\"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n");
    fprintf(f_out, "<plist version=\"1.0\">\n    <dict>\n");
    fprintf(f_out, "        <key>frames</key>\n        <dict>\n");
    fgets(s, 256, f_in); trim(s);
    while (strcmp(s, "</Asset>")) {
        sscanf(s + strlen("<Item><Key>"), "%s", frame_name);
        int len = strlen(frame_name);
        while (frame_name[--len] != '>');
        frame_name[len - strlen("</Key><Value>") + 1] = 0;
        sscanf(s + strlen("<Item></Key><Value><Key>") + strlen(frame_name),
            "%d%d%d%d", &img_x, &img_y, &img_width, &img_height);
        printf("INFO: Converting sprite frame %s\n", frame_name);
        fprintf(f_out, "            <key>%s</key>\n", frame_name);
        fprintf(f_out, "            <dict>\n");
        fprintf(f_out, "                <key>frame</key>\n");
        fprintf(f_out, "                <string>{{%d,%d},{%d,%d}}</string>\n",
            img_x, img_y, img_width, img_height);
        fprintf(f_out, "                <key>rotated</key>\n");
        fprintf(f_out, "                <false/>\n");
        fprintf(f_out, "            </dict>\n");
        /* Read the next line */
        fgets(s, 256, f_in); trim(s);
    }
    fprintf(f_out, "        </dict>\n");
    /* Write metadata information */
    fprintf(f_out, "        <key>metadata</key>\n");
    fprintf(f_out, "        <dict>\n");
    fprintf(f_out, "            <key>format</key>\n");
    fprintf(f_out, "            <integer>2</integer>\n");
    if (width > 0 && height > 0) {
        fprintf(f_out, "            <key>size</key>\n");
        fprintf(f_out, "            <string>{%d,%d}</string>\n", width, height);
    } else if ((width > 0) ^ (height > 0)) {
        printf("WARNING: Only got one of width and height. Ignoring.\n");
    }
    fprintf(f_out, "        </dict>\n");
    /* Finalize */
    fprintf(f_out, "    </dict>\n</plist>\n");
    
    fclose(f_in); fclose(f_out);
    printf("\nINFO: Successfully created your PLIST. Enjoy!\n");
    return 0;
}

int main(int argc, char **argv)
{
    int code = main_process(argc, argv);
    if (code != 0) {
        char errmsg[256];
        switch (code) {
            case 10: strcpy(errmsg, "FILE_ERROR"); break;
            default: strcpy(errmsg, "UNKNOWN_ERROR");
        }
        printf("\nERROR: Program exited with code: %d [%s]", code, errmsg);
    }
    return code;
}
