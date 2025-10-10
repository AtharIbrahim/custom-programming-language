
#include <iostream>
#include <thread>
#include <vector>
#include <mutex>
#include <chrono>

std::mutex cout_mutex;
int counter = 0;

void worker(int id) {
    for (int i = 0; i < 5; ++i) {
        {
            std::lock_guard<std::mutex> lock(cout_mutex);
            std::cout << "Worker " << id << " iteration " << i << std::endl;
            ++counter;
        }
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
}

int main() {
    std::cout << "Starting threaded computation..." << std::endl;
    
    std::vector<std::thread> threads;
    
    // Create 3 worker threads
    for (int i = 0; i < 3; ++i) {
        threads.emplace_back(worker, i + 1);
    }
    
    // Wait for all threads to complete
    for (auto& t : threads) {
        t.join();
    }
    
    std::cout << "All threads completed. Total counter: " << counter << std::endl;
    
    return 0;
}
