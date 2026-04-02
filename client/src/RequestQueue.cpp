#include "RequestQueue.h"

#include <map>
#include <string>
#include <format>

RequestQueue::RequestQueue()
{
    next_handle = 0;
}

QueueHandle RequestQueue::push(Entry entry)
{
    QueueHandle handle = std::format("0x{}", this->next_handle++);
    entries_waiting.insert({handle, entry});
    return handle;
}