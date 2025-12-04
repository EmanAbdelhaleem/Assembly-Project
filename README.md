
# Interactive Circular Queue (Assembly Language)

**Demo Video:** [LINK](https://youtu.be/8tfXKkZrkGM?si=rAaYYjyri3cJR11r)

This project implements a **fully interactive Circular Queue** in **x86 Assembly (TASM/MASM)** with a graphical visualization.
Users can push, pop, and inspect queue elements—while watching the queue update visually in real-time.

The goal of this project is to help students understand **circular queue mechanics**, **low-level memory operations**, and **interrupt-based graphics/text handling**.

---

## Features

* ✔️ Array-based **Circular Queue** (size = 10)
* ✔️ Supports core operations:

  * `Push`
  * `Pop`
  * `Front`
  * `Back`
  * `Display Queue`
  * `Is Full / Is Empty`
* ✔️ **On-screen diagram visualization** using BIOS interrupts
* ✔️ Custom **graphics drawing** (boxes, lines, cursor placement)
* ✔️ Manual cursor control in both **graphics** and **text modes**
* ✔️ Delay, clear screen, and utility functions for smooth UI

---

## How It Works

The program uses:

### **🔧 Data Section**

* Circular queue array
* Pointers (`queue_front`, `queue_back`)
* Counters (`count`)
* Flags (`flag_full`, `flag_empty`)
* UI strings (menu, prompts, error messages)

### **core Logic**

1. Displays a menu and waits for user input
2. Executes queue operations using:

   * Pointer arithmetic
   * `next` function to wrap indices
   * Graphics functions to visually update cells
3. Shows results in a mix of **text mode** and **graphics mode**

### **Visualization**

* Uses **INT 10h** to draw:

  * Rectangular queue diagram
  * Vertical lines separating cells
  * Elements inside the cells
* Cursor movement is handled manually to target the right pixel coordinates

---

### **Key Modules Inside `Queue.asm`:**

#### **1. Main Program**

* Menu loop
* User choice handling
* Program exit

#### **2. Display & System Utilities**

* `display_menu`
* `clear` (manual pixel clearing)
* `sleep` (nested loop delay)
* `graphics` (draws the queue box)

#### **3. Visualization Helpers**

* `cursor` → position cursor inside a queue cell
* `emplace_element` → draw pushed value
* `delete_element` → remove popped value

#### **4. Queue Operations**

* `initialize_queue`
* `push_back`
* `pop_front`
* `front`
* `back`
* `display_queue`
* `is_full`
* `is_empty`

#### **5. Low-Level Helpers**

* `next` (implements circular index = (index + 1) % size)
* `read_char`
* `display_char`
* `display_string`
* `endl`

---

## Requirements

To run the program you need:

* **TASM** or **MASM**
* **DOS / DOSBox** (recommended)
* Understanding of:

  * x86 registers
  * Interrupts (INT 10h, INT 21h)
  * Memory addressing

---

## 🚀 Running the Program

### 1️⃣ Assemble

```bash
tasm Queue.asm
```

### 2️⃣ Link

```bash
tlink Queue.obj
```

### 3️⃣ Run

```bash
Queue.exe
```

If using **DOSBox**, mount the project directory and run the commands inside DOSBox.

---

## 🧭 Usage Guide

Once the program starts:

1. The graphical queue diagram is drawn
2. A menu appears:

```
1. Push an element
2. Pop an element
3. Print the whole queue
4. Print the front
5. Print the back
6. Exit
```

3. Enter a number (1–6)
4. Interact with the queue visually and textually

