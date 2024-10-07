import pandas as pd;
import tkinter as tk;
import from tkinter{ttk,messagebox}

node Course {
    has name: str,
        difficulty: int,
        topics: list,
        prerequisites: list; 
}

edge prerequisite {
    has prereq_list: list[Course];
}

can clean_list(column_value: Any) -> list {
    if isinstance(column_value, str) {
        column_value = column_value.strip("[]").replace("'", "").split(",");
        return [item.strip() for item in column_value if item.strip()];
    }
    return [];
}

can load_courses() -> dict {
    df = pd.read_csv("courses.csv");
    df["topics"] = df["topics"].apply(clean_list);
    df["prerequisites"] = df["prerequisites"].apply(clean_list);

    courses_dict = {};

    for (index, row) in df.iterrows() {
        course_name = row["name"];
        courses_dict[course_name] = Course(
            name=course_name,
            difficulty=row['difficulty'],
            topics=row['topics'],
            prerequisites=row['prerequisites']
        );
    }

    return courses_dict;
}

can get_prerequisites_recursive(course_node: Course, visited: set, courses_dict: dict) -> list[Course] {
    if course_node.name in visited {
        return []; 
    }
    visited.add(course_node.name);

    prerequisites_list = [];
    for prereq_name in course_node.prerequisites {
        if prereq_name in courses_dict {
            prereq = courses_dict[prereq_name];
            prerequisites_list.append(prereq);
            prerequisites_list.extend(get_prerequisites_recursive(prereq, visited, courses_dict));
        }
    }

    return prerequisites_list; 
}

can suggested_next_courses(finished_courses: list, courses_dict: dict) -> list[str] {
    all_prerequisites = [];
    for course_name in finished_courses {
        if course_name in courses_dict {
            course_node = courses_dict[course_name];
            all_prerequisites.extend(get_prerequisites_recursive(course_node, set(), courses_dict));
        }
    }
    
    all_prerequisites = list(set(all_prerequisites));
    finished_courses_set = set([*finished_courses, *[prereq.name for prereq in all_prerequisites]]);

    next_courses = [];
    for course in courses_dict.values() {
        if course.name not in finished_courses_set and all([prereq in finished_courses_set for prereq in course.prerequisites]) {
            next_courses.append(course.name);
        }
    }

    return next_courses;
}

with entry {
    <>root = tk.Tk();
    <>root.title("Course Suggestion System");
    courses_dict = load_courses();

    finished_courses = [];

    can update_finished_courses() {
        :global: finished_courses;
        finished_courses = [course.strip() for course in finished_courses_entry.get().split(',') if course.strip()];
        finished_courses_listbox.delete(0, tk.END);
        for course in finished_courses {
            finished_courses_listbox.insert(tk.END, course);
        }
    }

    can show_suggested_courses() {
        suggested = suggested_next_courses(finished_courses, courses_dict);
        suggested_courses_listbox.delete(0, tk.END);
        for course in suggested {
            suggested_courses_listbox.insert(tk.END, course);
        }
    }

    # GUI components
    ttk.Label(<>root, text="Enter completed courses (comma-separated):").pack(pady=5);
    finished_courses_entry = ttk.Entry(<>root, width=50);
    finished_courses_entry.pack(pady=5);

    ttk.Button(<>root, text="Update Completed Courses", command=update_finished_courses).pack(pady=5);

    ttk.Label(<>root, text="Completed Courses:").pack(pady=5);
    finished_courses_listbox = tk.Listbox(<>root, width=50);
    finished_courses_listbox.pack(pady=5);

    ttk.Button(<>root, text="Show Suggested Courses", command=show_suggested_courses).pack(pady=5);

    ttk.Label(<>root, text="Suggested Next Courses:").pack(pady=5);
    suggested_courses_listbox = tk.Listbox(<>root, width=50);
    suggested_courses_listbox.pack(pady=5); 

    <>root.mainloop();
}