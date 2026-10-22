# Cub3D

<p align="center">
  <img src="https://img.shields.io/badge/Language-C-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/42-Project-black?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Graphics-MiniLibX-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Status-Completed-success?style=for-the-badge" />
</p>

A 42 School project where we built a small 3D engine using raycasting, inspired by classic FPS games.

---

## 👥 Authors

- **aychikhi**
- **ayaarab**

---

## 📌 Overview

Cub3D renders a first-person 3D view from a 2D map (`.cub`) in real time.  
The project focuses on graphics fundamentals, parsing, optimization, and clean C architecture.

Main goals:
- Parse and validate map/config files
- Render textured walls with depth
- Handle player movement and camera rotation
- Manage collisions and game loop stability

---

## ✨ Features

- Real-time raycasting renderer
- Different wall textures (N/S/E/W)
- Floor and ceiling color support
- WASD movement
- Left/right camera rotation
- Collision detection
- Error handling and clean exit

---

## 🛠️ Stack

- **C**
- **MiniLibX**
- **Makefile**
- **libft**

---

## 📁 Project Layout

```bash
.
├── includes/
├── src/
├── maps/
├── textures/
├── libft/
└── Makefile
```

---

## 🚀 Build & Run

```bash
make
./cub3D maps/map.cub
```

---

## 🎮 Controls

| Key | Action |
|-----|--------|
| W / A / S / D | Move |
| ← / → | Rotate camera |
| ESC | Exit |

---

## 🖼️ Screenshots

> Replace with your real images.

![Gameplay 1](./screenshots/gameplay-1.png)
![Gameplay 2](./screenshots/gameplay-2.png)
![Map Example](./screenshots/map-example.png)

---

## 📚 What We Learned

- Raycasting and 3D projection basics
- Texture mapping and coordinate handling
- Parsing and validation in C
- Memory management and debugging
- Team collaboration on a graphics project

---

## 🏫 42 Context

This project was developed as part of the 42 curriculum for educational purposes.
