#include <iostream>
using namespace std;

int main() {
    int number = 15;
    
    if (number > 10) {
        cout << number << " is greater than 10" << endl;
        
        if (number > 20) {
            cout << number << " is also greater than 20" << endl;
        } else {
            cout << number << " is not greater than 20" << endl;
        }
    } else {
        cout << number << " is not greater than 10" << endl;
    }
    
    return 0;
}