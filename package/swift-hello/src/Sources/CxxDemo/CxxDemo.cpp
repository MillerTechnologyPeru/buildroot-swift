#include "CxxDemo.h"

namespace demo {

int add(int lhs, int rhs) {
    return lhs + rhs;
}

std::string greeting(const std::string &name) {
    return "Hello from C++, " + name + "!";
}

} // namespace demo
