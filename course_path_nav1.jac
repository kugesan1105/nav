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

with entry {
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
    root ++> [course for course in courses_dict.values() if course.prerequisites == []];

    for (index, row) in df.iterrows() {
        course_name = row["name"];
        course_prerequisites = row["prerequisites"];

        for prereq_name in course_prerequisites {
            if prereq_name in courses_dict {
                courses_dict[prereq_name] +:prerequisite(prereq_list=[courses_dict[prereq_name]]):+> courses_dict[course_name];
            }
        }
    }

    print(
        "Graph structure created with custom 'prerequisite' edges."
    );
}

with entry {
    finished_courses = ['deep_learning','trigonometry'];

    can get_prerequisites_travel_up_recursive(course_node: Course, visited: set) -> list[Course] {
        # if course_node in visited {
        #     return []; 
        # }
        visited.add(course_node); # Mark the course as visited

        prerequisites_list = [];
        for prereq in [course_node<--] {
            prerequisites_list.append(prereq); 
            # prerequisites_list.extend(
            #     get_prerequisites_travel_up_recursive(prereq, visited)
            # );
            lll = get_prerequisites_travel_up_recursive(prereq, visited);
            for i in lll {
                if i not in prerequisites_list {
                    prerequisites_list.append(i);
                }
            }
        }

        return prerequisites_list; 
    }

    all_prerequisites =[];
    for i in finished_courses {
        course_node = courses_dict[i];
        all_prerequisites.extend(get_prerequisites_travel_up_recursive(course_node, set())); 
    }
    all_prerequisites = list(set([i for i in all_prerequisites if i != root]));
    print('\n\t All prerequisites');
    print([i.name for i in all_prerequisites]);
    finished_courses.extend([i.name for i in all_prerequisites]);
    print('\n\t Finished courses');
    print(finished_courses);
    print('\n\n');
    can suggested_next_courses() -> list[str] {
        next_courses = [];
        for i in all_prerequisites {
            new = [i.name for i in [i-->]];
            for j in new {
                if j not in finished_courses {
                    next_courses.append(j);
                }
            }
        }
        for j in [ x.name for x in [root -->]] {
            if j not in [*finished_courses,*all_prerequisites] {
                next_courses.append(j); 
            }
        }        
        return next_courses;
    }

    suggested_courses = suggested_next_courses();
    print(f"Suggested next courses: {suggested_courses}");
}
