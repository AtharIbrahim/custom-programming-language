
#include <iostream>
#include <vector>
#include <map>
#include <string>

template<typename T>
class Stack {
private:
    std::vector<T> items;

public:
    void push(const T& item) {
        items.push_back(item);
    }
    
    T pop() {
        if (items.empty()) {
            throw std::runtime_error("Stack is empty");
        }
        T item = items.back();
        items.pop_back();
        return item;
    }
    
    bool empty() const {
        return items.empty();
    }
    
    size_t size() const {
        return items.size();
    }
};

template<typename T>
T add(T a, T b) {
    return a + b;
}

int main() {
    // Test template function
    std::cout << "Template add: " << add(5, 3) << std::endl;
    std::cout << "Template add: " << add(3.14, 2.86) << std::endl;
    
    // Test template class
    Stack<int> intStack;
    Stack<std::string> stringStack;
    
    intStack.push(10);
    intStack.push(20);
    intStack.push(30);
    
    stringStack.push("Hello");
    stringStack.push("World");
    
    std::cout << "Int stack size: " << intStack.size() << std::endl;
    while (!intStack.empty()) {
        std::cout << "Popped: " << intStack.pop() << std::endl;
    }
    
    std::cout << "String stack:" << std::endl;
    while (!stringStack.empty()) {
        std::cout << "Popped: " << stringStack.pop() << std::endl;
    }
    
    return 0;
}
