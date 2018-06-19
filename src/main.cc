/**
 * @file   main.cc
 *
 * @section LICENSE
 *
 * The MIT License
 *
 * @copyright Copyright (c) 2018 TileDB, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#include <mutex>
#include <tbb/parallel_for.h>
#include <tiledb/tiledb>

int main() {
  // Create a TileDB context
  tiledb::Context ctx;
  // Print the version
  auto version = tiledb::version();
  std::cout << "You are using TileDB version " << std::get<0>(version) << "."
            << std::get<1>(version) << "." << std::get<2>(version) << std::endl;

  // Start some TBB tasks.
  std::mutex output_mtx;
  tbb::parallel_for(0, 10, 1, [&output_mtx](int i) {
    std::unique_lock<std::mutex> lck(output_mtx);
    std::cout << "TBB task " << i << " executing." << std::endl;
  });

  return 0;
}