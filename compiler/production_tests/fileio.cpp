
#include <iostream>
#include <fstream>
#include <string>
#include <stdexcept>

class FileManager {
public:
    static void writeFile(const std::string& filename, const std::string& content) {
        std::ofstream file(filename);
        if (!file.is_open()) {
            throw std::runtime_error("Cannot open file for writing: " + filename);
        }
        file << content;
        file.close();
    }
    
    static std::string readFile(const std::string& filename) {
        std::ifstream file(filename);
        if (!file.is_open()) {
            throw std::runtime_error("Cannot open file for reading: " + filename);
        }
        
        std::string content, line;
        while (std::getline(file, line)) {
            content += line + "\n";
        }
        file.close();
        return content;
    }
};

int main() {
    try {
        std::string filename = "test_output.txt";
        std::string content = "Hello from C++!\nThis is a test file.\nLine 3";
        
        std::cout << "Writing to file: " << filename << std::endl;
        FileManager::writeFile(filename, content);
        
        std::cout << "Reading from file:" << std::endl;
        std::string readContent = FileManager::readFile(filename);
        std::cout << readContent << std::endl;
        
        // Clean up
        std::remove(filename.c_str());
        std::cout << "File cleaned up." << std::endl;
        
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}
