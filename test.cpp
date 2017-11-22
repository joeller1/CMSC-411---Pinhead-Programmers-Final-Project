#include <iostream>

using namespace std;

// Type your code here, or load an example.

double factorial (double num) {
	double result = num;
	for (int i = 0; i < num; i++) {
		result *= (num - 1);
		num -= 1;
	}
	return result; 
}

double power (double num, int exp) {
	double result = num;
	for (int i = 0; i < (exp - 1); i++) {
        result *= num;
    }
	
    return result;
}

double taylor (double num) {

	double result = num;
	int n = -1;
    for (int i = 3; i < 10; i = i + 2) {
		result += n * (power(num, i) / factorial(i));
		n *= -1;
    }
    
    return result;
}
