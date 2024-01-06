from PIL import Image
R = 59
def on_edge(i, j):
    if (IS := intersect(i - 0.5)) is not None and abs(j) - 0.5 < IS:
        return True
    if (IS := intersect(i + 0.5)) is not None and abs(j) - 0.5 < IS:
        return True
    if (IS := intersect(j - 0.5)) is not None and abs(i) - 0.5 < IS:
        return True
    if (IS := intersect(j + 0.5)) is not None and abs(i) - 0.5 < IS:
        return True
    return False

def intersect(d: float):
    if abs(d) > R:
        return None
    return (R * R - d * d) ** (1/2)

array = []
for _ in range(119):
    array.append([False] * 119)
for i in range(-59, 60):
    for j in range(-59, 60):
        array[i + 59][j + 59] = int(on_edge(i, j))
        #array[i + 59][j + 59] = ((256, 256, 256), (0, 0, 0))[on_edge(i, j)]

with open(".\\circle.txt", "w") as file:
    for i in range(119):
        for j in range(119):
            if array[i][j]:
                file.write(f"                        (x==people_left{j-40:+} && y==people_up{i-40:+}) || \n")