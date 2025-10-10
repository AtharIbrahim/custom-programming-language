
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <memory>

class Person {
private:
    std::string name;
    int age;

public:
    Person(const std::string& n, int a) : name(n), age(a) {}
    
    std::string getName() const { return name; }
    int getAge() const { return age; }
    
    void display() const {
        std::cout << "Name: " << name << ", Age: " << age << std::endl;
    }
};

int main() {
    std::vector<Person> people = {
        Person("Alice", 25),
        Person("Bob", 30),
        Person("Charlie", 35)
    };
    
    std::cout << "People list:" << std::endl;
    for (const auto& person : people) {
        person.display();
    }
    
    // Find oldest person
    auto oldest = std::max_element(people.begin(), people.end(),
        [](const Person& a, const Person& b) {
            return a.getAge() < b.getAge();
        });
    
    std::cout << "Oldest person: " << oldest->getName() << std::endl;
    
    return 0;
}
