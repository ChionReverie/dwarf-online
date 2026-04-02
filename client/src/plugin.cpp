#include "Debug.h"
#include "PluginManager.h"

// #include <curl/curl.h>
#include <cpr/cpr.h>

#include <string>
#include <vector>

#include "RequestQueue.h"

using std::string;
using std::vector;

using namespace DFHack;

DFHACK_PLUGIN("dwarf_online");

namespace DFHack
{
    DBG_DECLARE(dwarf_online, log);
}

static RequestQueue *_queue;


RequestQueue *queue()
{
    if (!_queue)
    {
        _queue = new RequestQueue();
    }
    return _queue;
}

static command_result do_command(color_ostream &out, vector<string> &parameters);

DFhackCExport command_result plugin_init(color_ostream &out, vector<PluginCommand> &commands)
{
    DEBUG(log, out).print("initializing %s\n", plugin_name);

    commands.push_back(PluginCommand(
        plugin_name,
        "Test of commands api",
        do_command));

    return CR_OK;
}

DFhackCExport command_result plugin_shutdown(color_ostream &out)
{
    return CR_OK;
}

static command_result do_command(color_ostream &out, vector<string> &parameters)
{
    auto url = "http://localhost:8080/health";
    out.print("Fetching %s!\n", url);

    cpr::Response res = cpr::Get(cpr::Url(url));
    out.print("Response: %ld!\n", res.status_code);


    // CURLcode res = curl_global_init(CURL_GLOBAL_ALL);
    // CURL *curl = curl_easy_init();
    // if (curl)
    // {
    //     curl_easy_setopt(curl, CURLOPT_URL, url);
    //     curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    //     res = curl_easy_perform(curl);
    //     if (res != CURLE_OK)
    //     {
    //         out.print("curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
    //     }
    //     else {
    //         out.print("Success!");
    //     }
    //     curl_easy_cleanup(curl);
        
    // }
    // curl_global_cleanup();

    return CR_OK;
}
