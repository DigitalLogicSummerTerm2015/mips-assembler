#include <iostream>

int gcd(unsigned a, unsigned b)
{
    if ((a && b) == 0)
        return 0;

    do
    {
        while (a >= b)
            a -= b;

        int temp = a;
        a = b;
        b = temp;
    } while (b != 0);  // b is always smaller.

    return a;
}

int main()
{
    using namespace std;

    unsigned a, b;

    while (cin >> a >> b)
        cout << gcd(a, b) << endl;

    return 0;
}
