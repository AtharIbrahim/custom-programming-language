
#include <iostream>
#include <memory>
#include <vector>

class Resource {
private:
    std::string name;
    int* data;

public:
    Resource(const std::string& n, int size) : name(n) {
        data = new int[size];
        for (int i = 0; i < size; ++i) {
            data[i] = i * i;
        }
        std::cout << "Resource '" << name << "' created" << std::endl;
    }
    
    ~Resource() {
        delete[] data;
        std::cout << "Resource '" << name << "' destroyed" << std::endl;
    }
    
    void display() const {
        std::cout << "Resource: " << name << std::endl;
    }
    
    // Disable copy to demonstrate unique ownership
    Resource(const Resource&) = delete;
    Resource& operator=(const Resource&) = delete;
};

void demonstrateUniquePtr() {
    std::cout << "=== Unique Pointer Demo ===" << std::endl;
    auto resource = std::make_unique<Resource>("UniqueResource", 10);
    resource->display();
    // Resource automatically destroyed when unique_ptr goes out of scope
}

void demonstrateSharedPtr() {
    std::cout << "=== Shared Pointer Demo ===" << std::endl;
    auto resource1 = std::make_shared<Resource>("SharedResource", 5);
    {
        auto resource2 = resource1; // Share ownership
        std::cout << "Reference count: " << resource1.use_count() << std::endl;
        resource2->display();
    }
    std::cout << "Reference count after scope: " << resource1.use_count() << std::endl;
    // Resource destroyed when last shared_ptr is destroyed
}

int main() {
    demonstrateUniquePtr();
    std::cout << std::endl;
    demonstrateSharedPtr();
    
    return 0;
}
