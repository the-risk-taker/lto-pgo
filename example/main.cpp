#include "process.hpp"
#include <chrono>
#include <cstdint>
#include <iostream>
#include <numeric>
#include <vector>

// Function that processes data. The hot path is very predictable.
void run_logic(std::vector<int64_t>& vec)
{
    for (auto& val : vec)
    {
        // 99% of cases will go into the 'if' branch. This is a key point for PGO.
        if (val < 99000)
        {
            process_hot(val);
        }
        else
        {
            process_cold(val);
        }
    }
}

int main()
{
    static constexpr int iterations = 10;
    static constexpr size_t size = 20'000'000;
    std::vector<int64_t> data(size);
    std::iota(data.begin(), data.end(), 0);

    const auto start = std::chrono::high_resolution_clock::now();

    for (int i = 0; i < iterations; ++i)
    {
        run_logic(data);
        // "Reset" the data to avoid the influence of the previous iteration, while keeping a predictable pattern.
        std::iota(data.begin(), data.end(), 0);
    }

    const auto end = std::chrono::high_resolution_clock::now();
    const auto milliseconds = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);

    // Use the sum to prevent the compiler from optimizing away the calculations
    const auto sum = std::accumulate(data.begin(), data.end(), 0LL);
    std::cout << "Total execution time: " << milliseconds.count() << "ms, result = " << sum << "\n";

    return 0;
}
