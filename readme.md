## Im Jupyter Notebook Terminal:


```
# Installiert alle benötigten System-Tools (cmake, libcurl)
!apt-get update && apt-get install -y cmake libcurl4-openssl-dev

# Klont llama.cpp (falls noch nicht vorhanden) und kompiliert es mit der neuen CMake-Methode
!git clone https://github.com/ggerganov/llama.cpp.git
!cd llama.cpp && rm -rf build && mkdir build && cd build && cmake .. && cmake --build .

print("\n✅ Vorbereitung abgeschlossen. Llama.cpp ist jetzt kompiliert.")
```


