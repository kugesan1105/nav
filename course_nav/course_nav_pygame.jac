import pandas as pd;
import pygame;
import from window_config { InputBox, Button }
import from utils { clean_list }

node Course {
    has name: str,
        difficulty: int,
        topics: list,
        prerequisites: list,
        visited: bool = False;
}

edge prerequisite {
    has prereq_list: list[Course];
}

walker CreateGraph {
    has csv_path: str,
        courses_dict: dict[str, Course] = {};

    has visited: set[Courses] = set();

    can create_graph with `root entry {
        df = pd.read_csv(self.csv_path);
        df["topics"] = df["topics"].apply(clean_list);
        df["prerequisites"] = df["prerequisites"].apply(clean_list);
        
        for (index, row) in df.iterrows() {
            course_name = row["name"];

            course = Course(
                name=course_name,
                difficulty=row['difficulty'],
                topics=row['topics'],
                prerequisites=row['prerequisites']
            );
            self.courses_dict[course_name] = course;
        }

    }

    can connect_root with `root entry {
        root ++> [course for course in self.courses_dict.values() if course.prerequisites == []];
        print([-->]);
    }

    can connect_prerequisites with `root entry {
        for item in self.courses_dict.items() {
            course_name = item[0];
            course_prerequisites = item[1].prerequisites;
            for prereq_name in course_prerequisites {
                if prereq_name in self.courses_dict {
                    self.courses_dict[prereq_name] +:prerequisite(prereq_list=[self.courses_dict[prereq_name]]):+> self.courses_dict[course_name];
                }
            }
        }
    }

}

walker CourseRecommender {
    has finished_courses: list[Course] = [root],
        suggested_courses: list[Course] = [];

    can get_prerequisites_travel_up_recursive with Course entry -> None {
        if here.visited {
            return;
        }
        prerequisites_list = [];
        for prereq in [here<--] {
            if prereq not in [*self.finished_courses, root] {
                prerequisites_list.append(prereq);
                self.finished_courses.append(prereq);
            }
        }
        visit prerequisites_list;
        return;
    }

    can suggest_next_courses with Course entry {
        next_courses = set();
        
        for course in self.finished_courses {
            potential_next = [c for c in [course-->] if c not in self.finished_courses];
            for next_course in potential_next {
                if all(
                    [prereq in self.finished_courses for prereq in [next_course<--]]
                ) {
                    next_courses.add(next_course);
                }
            }
        }
        self.suggested_courses = list(next_courses);
    }

}

enum Color {
    BLACK = (0, 0, 0),
    GREY = (100, 100, 100),
    LIGHT_BLUE = (0, 191, 255),
    LIGHT_RED = (240, 255, 255),
    LIGHT_GREEN = (144, 238, 144),
    SNOW = (255, 250, 250)
}

walker GUI {

    has running: bool = True,
        mouse_pos: Any = None,
        mouse_pressed: Any = None,
        finished_courses: list[str] = [],
        suggested_courses: list[str] = [],
        screen: Any = None,
        font: Any = None,
        input_font: Any = None,
        input_text: str = '',
        displayed_text: str = '',
        went: bool = False,
        suggest_button: Button by postinit,
        retry_button: Button by postinit,
        input_box: InputBox by postinit;

    can postinit {
        self.suggest_button = Button(
            300,
            200,
            120,
            40,
            Color.LIGHT_RED.value,
            Color.LIGHT_GREEN.value,
            'Suggest'
        );
        self.retry_button = Button(
            500,
            700,
            100,
            50,
            Color.SNOW.value,
            Color.LIGHT_BLUE.value,
            'Retry'
        );
        self.input_box = InputBox(
            100,
            150,
            700,
            40,
            Color.GREY.value,
            Color.LIGHT_GREEN.value
        );
    }

    can create_window with `root entry {
        pygame.<>init();
        (WIDTH, HEIGHT) = (800, 800);
        self.screen = pygame.display.set_mode((WIDTH, HEIGHT));
        pygame.display.set_caption('Course Path Navigator');
        self.font = pygame.font.Font(None, 36);
        self.input_font = pygame.font.Font(None, 12);
        self.input_text = '';
        self.displayed_text = '';

    }

    can get_mouse_pos {
        self.mouse_pos = pygame.mouse.get_pos();
        self.mouse_pressed = pygame.mouse.get_pressed();
        
        for event in pygame.event.get() {
            if event.type == pygame.QUIT {
                self.running = False;
            }
            self.input_box.handle_event(event);
        }
    }

    can handle_buttons {
        self.suggest_button.draw(self.screen, self.mouse_pos);
        self.retry_button.draw(self.screen, self.mouse_pos);
        if self.suggest_button.is_clicked(
            self.mouse_pos,
            self.mouse_pressed
        ) {
            self.update_displayed_text();
        }
        if self.retry_button.is_clicked(
            self.mouse_pos,
            self.mouse_pressed
        ) {
            self.retry();
        }
    }

    can update_finished_courses(x: str) {
        self.finished_courses = [course.strip() for course in x.split(',') if course.strip()];
    }

    can show_suggested_courses -> list[str] {
        recommender = CourseRecommender();
        
        for course in self.finished_courses {
            recommender.finished_courses.append(
                G.courses_dict.get(course)
            );
        }
        
        for course in self.finished_courses {
            current_course = G.courses_dict[course];
            current_course spawn recommender;
        }
        recommender.suggest_next_courses;
        suggested = recommender.suggested_courses;
        return [i.name for i in suggested];
    }

    can update_displayed_text {
        try  {
            self.update_finished_courses(self.input_box.text);
            self.suggested_courses = self.show_suggested_courses();
            self.displayed_text = self.suggested_courses;
        } except Exception as e {
            self.displayed_text = 'Invalid input. Please try again.';
            self.went = True;
        }
    }

    can retry {
        self.finished_courses.clear();
        self.input_text = '';
        self.displayed_text = '';
    }

    can run with `root entry {
        
        while self.running {
            self.screen.fill((220, 220, 220));
            descrption = self.font.render(
                    'Enter the courses you have completed separated by commas:',
                    True,
                    Color.BLACK.value
                );
            self.screen.blit(descrption, (100, 100));
            self.get_mouse_pos();
            self.handle_buttons();

            self.input_box.draw(self.screen);

            if self.went {
                display_surface = self.font.render(
                    self.displayed_text,
                    True,
                    Color.BLACK.value
                );
                self.screen.blit(display_surface, (100, 300));
            } else {
                for i in range(len(self.displayed_text)) {
                    display_surface = self.font.render(
                        self.displayed_text[i],
                        True,
                        Color.BLACK.value
                    );
                    self.screen.blit(display_surface, (100, 300 + i * 50));
                }
            }
            pygame.display.flip();
            pygame.time.Clock().tick(30);
        }
        pygame.quit();
    }

}

with entry {
    G = CreateGraph(csv_path='courses.csv');
    root spawn G;
    print(len(G.courses_dict));

    gui = GUI();
    root spawn gui;

}
