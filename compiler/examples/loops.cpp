#include <iostream>
using namespace std;

int main() {
    int i = 1;
    
    cout << "While loop from 1 to 5:" << endl;
    while (i <= 5) {
        cout << "i = " << i << endl;
        i = i + 1;
    }
    
    cout << "For loop from 1 to 5:" << endl;
    for (int j = 1; j <= 5; j = j + 1) {
        cout << "j = " << j << endl;
    }
    
    return 0;
}