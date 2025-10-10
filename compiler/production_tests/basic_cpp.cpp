// Basic C++ test compatible with older standards
#include <iostream>
#include <string>

class Calculator {
private:
    int value;

public:
    Calculator() : value(0) {}
    Calculator(int v) : value(v) {}
    
    int add(int n) {
        value += n;
        return value;
    }
    
    int multiply(int n) {
        value *= n;
        return value;
    }
    
    int getValue() const {
        return value;
    }
    
    void display() const {
        std::cout << "Calculator value: " << value << std::endl;
    }
};

int main() {
    Calculator calc(10);
    
    std::cout << "Starting with: " << calc.getValue() << std::endl;
    
    calc.add(5);
    std::cout << "After adding 5: " << calc.getValue() << std::endl;
    
    calc.multiply(2);
    std::cout << "After multiplying by 2: " << calc.getValue() << std::endl;
    
    calc.display();
    
    return 0;
}