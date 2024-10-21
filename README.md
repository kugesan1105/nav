#  Course Path Navigator
This repository contains the source code for a Course Path Navigator, a Graphica application developed in Jac-Lang that suggests the next courses a user should take based on their completed courses. The application uses DataSpatial Features of Jaclang and GUI (pygame) interaction, making it a helpful tool for educational purposes or course path recommendations.

## Features
- Course Recommendation Engine: The application builds a course dependency graph from a CSV file, allowing it to suggest which courses are appropriate based on the prerequisites.
- Interactive GUI: A graphical user interface (built with Pygame) allows users to input completed courses and retrieve suggested next courses.
- Graph Construction: Courses are represented as nodes in a graph, and prerequisites as directed edges between nodes, facilitating traversal.
- Customizable Course Data: Courses, topics, and prerequisites are easily configurable via a CSV file.

## Usage
  1. Add Completed Courses:
      - Launch the application, and a window will appear prompting you to enter the courses you have completed, separated by commas.

  2. Get Course Recommendations:
      - Once you hit the "Suggest" button, the application will process your input and display the next recommended courses based on the graph traversal of the prerequisites.
  3. Retry Button:
       - Use the retry button to clear the input and try again with different courses.

### Watch a demo of the Course Path Navigator:
<p align="center">
  <a href="https://youtu.be/922ijWWy2y0">
    <img src="https://img.youtube.com/vi/922ijWWy2y0/maxresdefault.jpg" alt="Course Path Navigator Demo" title="Course Path Navigator Demo" width="30%" style="border: 2px solid #555; border-radius: 10px;">
  </a>
</p>

![image](https://github.com/user-attachments/assets/1ce456f5-1aa1-49cb-b73c-3bb3c330341c)
