#pragma once
#include <cstdint>

// Two simple functions that will be candidates for inlining. Placed in a separate translation unit to demonstrate the power of LTO.
void process_hot(int64_t& data);
void process_cold(int64_t& data);
