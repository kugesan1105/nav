import:py pygame;

with entry {
    pygame.<>init();
    (WIDTH, HEIGHT) = (600, 400);
    WHITE = (255, 255, 255);
    BLACK = (0, 0, 0);
    GREY = (100, 100, 100);
    BLUE = (0, 0, 255);
    LIGHT_BLUE = (173, 216, 230);
    RED = (255, 0, 0);
    LIGHT_RED = (255, 102, 102);
    screen = pygame.display.set_mode((WIDTH, HEIGHT));
    pygame.display.set_caption('Text Input and Buttons');
    font = pygame.font.Font(None, 36);
    input_font = pygame.font.Font(None, 32);
    input_text = '';
    displayed_text = '';
    active = False;
}

class Button {
    can init(self:Button,x: Any, y: Any, w: Any, h: Any, color: Any, hover_color: Any, text: Any, action: Any=None) {
        self.rect = pygame.Rect(x, y, w, h);
        self.color = color;
        self.hover_color = hover_color;
        self.text = text;
        self.action = action;
    }

    can draw(self: Button, screen: Any, mouse_pos: Any) {
        if self.rect.collidepoint(mouse_pos) {
            pygame.draw.rect(screen, self.hover_color, self.rect);
        } else {
            pygame.draw.rect(screen, self.color, self.rect);
        }
        text_surf = font.render(self.text, True, BLACK);
        screen.blit(
            text_surf,
            ((self.rect.x + ((self.rect.width - text_surf.get_width()) / 2)), (self.rect.y + ((self.rect.height - text_surf.get_height()) / 2)))
        );
    }

    can is_clicked(self: Button, mouse_pos: Any, mouse_pressed: Any) -> Any {
        return self.rect.collidepoint(mouse_pos)
            and mouse_pressed[0];
    }
}

class InputBox {
    can init(self:InputBox ,x: Any, y: Any, w: Any, h: Any, color_inactive: Any, color_active: Any) {
        self.rect = pygame.Rect(x, y, w, h);
        self.color_inactive = color_inactive;
        self.color_active = color_active;
        self.color = color_inactive;
        self.text = '';
        self.active = False;
        self.cursor_visible = True;
        self.cursor_counter = 0;
    }

    can handle_event(self: InputBox, event: Any) {
        if event.type == pygame.MOUSEBUTTONDOWN {
            if self.rect.collidepoint(event.pos) {
                self.active = True;
            } else {
                self.active = False;
            }
            self.color = self.color_active if self.active else self.color_inactive;
        }
        if event.type == pygame.KEYDOWN and self.active {
            if event.key == pygame.K_BACKSPACE {
                self.text = self.text[:-1];
            } else {
                self.text += event.unicode;
            }
        }
    }

    can draw(self: InputBox, screen: Any) {

        pygame.draw.rect(screen, self.color, self.rect, 2);
        txt_surface = input_font.render(self.text, True, BLACK);
        screen.blit(
            txt_surface,
            ((self.rect.x + 5), (self.rect.y + 5))
        );
        self.cursor_counter += 1;
        if self.active and self.cursor_visible {
            pygame.draw.line(
                screen,
                BLACK,
                (((self.rect.x + 5) + txt_surface.get_width()), (self.rect.y + 5)),
                (((self.rect.x + 5) + txt_surface.get_width()), ((self.rect.y + self.rect.height) - 5)),
                2
            );
        }
        if self.cursor_counter >= 30 {
            self.cursor_counter = 0;
            self.cursor_visible = not self.cursor_visible;
        }
    }
}
