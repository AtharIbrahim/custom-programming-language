#include <iostream>
using namespace std;

int main() {
    int x = 10;
    float y = 3.14;
    bool flag = true;
    
    cout << "Integer: " << x << endl;
    cout << "Float: " << y << endl;
    cout << "Boolean: " << flag << endl;
    
    // Type conversions
    float converted = x + y;
    cout << "Mixed arithmetic: " << converted << endl;
    
    // Boolean operations
    bool result1 = (x > 5) && flag;
    bool result2 = (x < 5) || flag;
    
    cout << "Boolean AND result: " << result1 << endl;
    cout << "Boolean OR result: " << result2 << endl;
    
    return 0;
}