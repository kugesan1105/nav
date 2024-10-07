import:py pandas as pd;

node Course {
    has name: str,
        difficulty: int,
        topics: list,
        prerequisites: list;  # List of other course names that are required before this course

}


can clean_list(column_value: Any) -> list {
    if isinstance(column_value, str) {

        column_value = column_value.strip("[]").replace("'", "").split(",");    
        return [item.strip() for item in column_value if item.strip()] ;
    }
    
    return [] ;
}

with entry {
    df = pd.read_csv("courses.csv");
    df["topics"] = df["topics"].apply(clean_list);    
    df["prerequisites"] = df["prerequisites"].apply(clean_list);    
    courses_dict = {};
    for (index, row) in df.iterrows() {
        course_name = row["name"];
        course_topics = row["topics"];
        course_prerequisites = row["prerequisites"];
        courses_dict[course_name] = Course(
            name=course_name,
            difficulty=row['difficulty'],
            topics=course_topics,
            prerequisites=course_prerequisites
        );

    }
    # connect root with first node
    root ++> courses_dict["python_basics"];
    for (index, row) in df.iterrows() {
        course_name = row["name"];
        course_prerequisites = row["prerequisites"];

        # Connect current course to its prerequisites
        for prereq_name in course_prerequisites {
            if prereq_name in courses_dict {
                # Connecting prerequisite nodes to the current course
                courses_dict[prereq_name] ++> courses_dict[course_name];
                # print(f"Connected {prereq_name} to {course_name}");
            }
        }
    }
print("Graph structure created based on courses and prerequisites.");
}