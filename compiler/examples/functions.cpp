#include <iostream>
using namespace std;

int add(int a, int b) {
    return a + b;
}

int multiply(int x, int y) {
    int result = x * y;
    return result;
}

int main() {
    int num1 = 5;
    int num2 = 3;
    
    int sum = add(num1, num2);
    int product = multiply(num1, num2);
    
    cout << "Numbers: " << num1 << " and " << num2 << endl;
    cout << "Sum: " << sum << endl;
    cout << "Product: " << product << endl;
    
    return 0;
}