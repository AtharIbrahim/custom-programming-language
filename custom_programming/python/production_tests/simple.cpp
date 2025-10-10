// Simple C++ program with no C++11+ features
#include <iostream>

int factorial(int n) {
    if (n <= 1) {
        return 1;
    }
    return n * factorial(n - 1);
}

int main() {
    int numbers[] = {1, 2, 3, 4, 5, 6};
    int size = sizeof(numbers) / sizeof(numbers[0]);
    
    std::cout << "Factorial calculations:" << std::endl;
    
    for (int i = 0; i < size; i++) {
        int num = numbers[i];
        int result = factorial(num);
        std::cout << "factorial(" << num << ") = " << result << std::endl;
    }
    
    return 0;
}