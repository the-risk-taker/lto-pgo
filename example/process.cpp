#include "process.hpp"

// Intentionally simple so that the cost of calling the function is significant compared to its body.
void process_hot(int64_t& data)
{
    data += 1;
}

// Perform more complex and less frequently used operations to mark this as a cold path.
void process_cold(int64_t& data)
{
    data *= 2;
    data -= 5;
    data ^= 0xDEADBEEF;
}
