

can clean_list(column_value: any) -> list {
    if isinstance(column_value, str) {
        column_value = column_value.strip("[]").replace("'", "").split(",");
        return [item.strip() for item in column_value if item.strip()];
    }
    return [];
}

