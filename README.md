# 🌳 Phylogenetic Tree Visualizer

An interactive viewer of phylogenetic trees in radial layout, developed in Processing (Java).

## ✨ Features

- 🎨 Radial view with colored branches
- 🖼️ Support for images for nodes
- 🔍 Zoom and drag navigation
- ✏️ Real-time node editing (name and color)
- 💾 Tree export in Newick format
- 📝 Subtitles for color legend

## ⚙️ How to Use

1. **Data preparation**:
- Get your own NWK file, no need to add the color tags beforehand
- Add PNG images for nodes in the `data/png/` folder (optional)
- The PNG files name must be the same name as your node's name
- The images are better suited in square format

2. **Newick tree format change**:
- Use `#RRGGBB` in node names to define colors
- Example: `(Mammal#FF5733:0.5,Bird#33FF57:0.7)Vertebrate#FFFF33:1.0`

3. **Execution**:
- Change the folder name to `ancient_field`
- Open `ancient_field.pde` with Processing
- Run the main sketch

4. **Controls:**

- Mouse scroll: Zoom in/out
- Drag: Move the view
- Click on a node: Edit properties

5. **Menu:**

- File: Load/Save trees, Export image
- Options: Reset view, Show captions
- About: Help and information

## 🌿 Example Tree
```
(((Mammal#FF5733:0.5,Bird#33FF57:0.7)Vertebrate#FFFF33:1.0,((Arthropod#FF33FF:0.8,Mollusca#33FFFF:0.6)Invertebrate#CCCCCC:1.2,Plant#33FF33:1.5))Living_Creatures:2.0,Virus#7F007F:1.0)Root;
```

## 📂 File Structure
```
ancient_field/
├── data/
│ ├── testTree.nwk (Example tree)
│ └── png/ (Images folder, not included)
│   ├── Mammal.png
│   ├── Bird.png
│   ├── Arthropod.png
│   ├── Mollusca.png
│   ├── Plant.png
│   └── Virus.png
├── ancient_field.pde (Main code)
├── JMenu.pde (Java Swing section of the code)
├── .gitignore
└── README.md (This file)
```

## 🧪 Requirements:

- [Processing 4.0+](https://processing.org/download)
- Java 11+
- No external libraries required

## 👥 Contribution

- Contributions are welcome! Please open an issue or pull request.

## 🤖 AI Disclaimer

- This code was made with the assistance of AI tools, but I'm aware of what it does
- The Swing section of it was made entirely by me, derived from [NChess](https://github.com/A11v1r15/NChess)

## 📜 License

- MIT License - Free for academic and personal use.