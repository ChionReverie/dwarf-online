#pragma once

#include <string>
#include <map>
#include <chrono>
#include <functional>

typedef std::string QueueHandle;

struct Entry;
typedef std::function<void(Entry)> callback_OnSuccess;
typedef std::function<void(Entry)> callback_OnError;
struct Entry
{
    std::chrono::time_point<std::chrono::utc_clock> timeout;
    std::optional<callback_OnSuccess> on_success;
    std::optional<callback_OnError> on_error;
    void *request; // TODO
    std::optional<void *> response;
};

struct RequestQueue
{
    int next_handle;
    std::map<std::string, Entry> entries_waiting;

    RequestQueue();
    ~RequestQueue();

    QueueHandle push(Entry entry);
    void resolve_reponses();
};
