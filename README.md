# GK Hemanth - Personal Portfolio Website

A modern, responsive, high-performance portfolio website built for **GK Hemanth**, Computer Science student at **Jain (Deemed-to-be University)**, Bangalore.

This portfolio showcases verified **LinkedIn Learning certifications**, core technical competencies across **Graph Neural Networks**, **Computer Architecture**, and **Discrete Mathematics**, featured projects, and includes a **fully functioning contact form** backed by a local server.

---

## 🎓 Featured LinkedIn Certifications

The portfolio highlights three verified LinkedIn Learning credentials earned by G K Hemanth (authorized by Shea Hanson, Head of Learning Content Strategy):

1. **Computer Architecture Essentials**
   - **Date Completed:** September 22, 2026 (4 hours 47 minutes)
   - **Top Skills Covered:** Programming Languages, Computer Hardware
   - **Certificate ID:** `4e25ba83abcdf7e2a778c5d4955a648e82be25ebcf007434750a22e81d12560c`
   - **File:** `assets/certificates/computer-architecture-essentials.pdf`

2. **Programming Foundations: Discrete Mathematics**
   - **Date Completed:** September 23, 2026 (3 hours 9 minutes)
   - **Top Skills Covered:** Discrete Mathematics, Programming Foundations
   - **Certificate ID:** `e4d9eed96531d360d055d72ca369bcf02d5b110a2d01d4278f3b22d0a0d08683`
   - **File:** `assets/certificates/programming-foundations-discrete-mathematics.pdf`

3. **Learning Graph Neural Networks**
   - **Date Completed:** September 28, 2026 (2 hours 13 minutes)
   - **Top Skills Covered:** Neural Networks, Graph Networks, Artificial Intelligence (AI)
   - **Certificate ID:** `3166ad55658d1897f9ef19c764a1f48ecf0866ec7d8d5ce2f7f83193af2d2d9b`
   - **File:** `assets/certificates/learning-graph-neural-networks.pdf`

---

## 🌟 Key Features

- **Interactive Certificate Showcase**:
  - Filter by domain (AI & GNNs, Systems & Hardware, Discrete Math).
  - One-click **Copy Certificate ID** with clipboard feedback.
  - Interactive **PDF Preview Modal** and direct **PDF Download** buttons.
- **Interactive Contact Form**:
  - Validates user input in real-time.
  - Submits to `/api/contact` backend API.
  - Automatically appends inquiries to `data/messages.json`.
  - Fallback local browser caching ensures no message is lost.
- **Glassmorphism & High-Tech Visuals**:
  - Dual theme support: **Dark Mode** and **Light Mode** (persists in localStorage).
  - Animated typing effect in Hero section.
  - Interactive skill progress bars and project cards.
  - Fully responsive on mobile, tablet, and desktop screens.
- **Self-Contained Localhost Server**:
  - Zero external dependencies: powered by native PowerShell `TcpListener`.
  - Automatically handles static assets and JSON API endpoints.

---

## 🚀 Running on Localhost

To start the local web server:

### Option 1: Double-Click Batch File
Double-click `start-server.bat` in this folder.

### Option 2: PowerShell Command
```powershell
powershell -ExecutionPolicy Bypass -File .\server.ps1 -Port 3000
```

Once started, open your web browser and visit:
👉 **`http://localhost:3000`**

---

## 📂 Project Structure

```text
gk-hemanth-portfolio/
├── index.html                 # Main single-page portfolio layout
├── styles.css                 # Glassmorphism, animations, dark/light themes
├── script.js                  # Interactivity, typing, cert modal, contact form
├── server.ps1                 # Localhost HTTP & API server
├── start-server.bat           # One-click Windows starter batch script
├── README.md                  # Project documentation
├── assets/
│   └── certificates/          # Official LinkedIn Learning PDF certificates
│       ├── computer-architecture-essentials.pdf
│       ├── programming-foundations-discrete-mathematics.pdf
│       └── learning-graph-neural-networks.pdf
└── data/
    └── messages.json          # Submissions from contact form
```
