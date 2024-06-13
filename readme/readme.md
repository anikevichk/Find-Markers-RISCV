# Image Processing Assembly Code

This assembly code is designed to process a BMP image (`sourcee.bmp`) and perform specific operations related to identifying and manipulating pixels.

## Purpose

The main goal of this assembly program is to locate and process corners under number 2 within the BMP image.

## Key Components

### Constants

- `BMP_FILE_SIZE`: Defines the expected size of the BMP file (`230522` bytes).
- `BYTES_PER_ROW`: Specifies the number of bytes per row in the BMP image (`960` bytes).
- Registers `x`, `y`, `cx`, `cy` are used throughout the code to manage pixel coordinates and counters.

### Data Section

- `.asciz` directives define strings for newline (`nline`) and comma (`coma`) characters.
- Error messages (`oerror` for file opening error, `terror` for wrong file type error).

### Initialization (`init`)

- Checks the type of the BMP file.
- Reads the BMP file (`sourcee.bmp`) into memory (`image`).
- Sets up initial parameters (`s0` for image width, `s1` for image height).

### Main Processing Loops

- **Row and Column Loops**: Iterate through each pixel of the image.
- **Find Corner**: Detects corners based on neighboring pixel values.
- **Check Extremes (Horizontal and Vertical)**: Checks adjacent pixels to determine boundaries.
- **Calculate Lengths**: Measures lengths based on detected corners and boundaries.

### Error Handling

- Handles errors such as file opening failure or incorrect file type.

### Printing and Output

- Outputs coordinates and results based on the processing performed.

## How to Run

1. **Environment Setup**: Ensure an environment that supports MIPS assembly execution.
2. **File Placement**: Place `sourcee.bmp` in the same directory as the executable.
3. **Execution**: Run the executable, which will process `sourcee.bmp`.

