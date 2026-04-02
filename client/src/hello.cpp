#include <stdio.h>

#include <cpr/cpr.h>

int add(int a, int b) {
    return a + b;
}

int main(int argc, char const *argv[])
{
    auto url = "http://localhost:8080/health";
    printf("Fetching %s!\n", url);

    cpr::Response res = cpr::Get(cpr::Url(url));
    printf("Response: %ld!\n", res.status_code);
    
    return 0;
}
