import glfw
import numpy as np
from OpenGL.GL import *
import math
from PIL import Image
import time

import csv

size = 0.5
angle = 0.0
angle2 = 0
n = 50
flag = True
texture = 0
speed = 0
direction = [0, 1, 0, 5]
delta_x = 0
delta_y = 0.5
delta_z = 0

im = Image.open('texture.jpg')
width = im.width
height = im.height

l_frame = 0.0
f_count = 0
fps = 0.0

display_list = 0
vbo = 0

vertices = []
normals = []
indices = []

fps_list = [('Number', 'FPS')]
fps_count = 0
def count_fps():
    global fps, l_frame, f_count, fps_list, fps_count
    current = time.time()
    delta = current - l_frame
    f_count += 1
    if delta >= 1.0:
        fps = f_count / delta
        fps_list.append((fps_count, fps))
        f_count = 0
        l_frame = current
        fps_count += 1


def getnorm(a, b, c):
    mult = 0
    n = [0] * 3
    n[0] = (b[1] - a[1]) * (c[2] - a[2]) - (b[2] - a[2]) * (c[1] - a[1])
    n[1] = (c[0] - a[0]) * (b[2] - a[2]) - (b[0] - a[0]) * (c[2] - a[2])
    n[2] = (b[0] - a[0]) * (c[1] - a[1]) - (c[0] - a[0]) * (b[1] - a[1])
    for i in range(3):
        mult += a[i] * n[i]
    if mult < 0:
        for j in range(3):
            n[j] = -n[j]
    a = [b[0] - a[0], b[1] - a[1], b[2] - a[2]]
    b = [c[0] - a[0], c[1] - a[1], c[2] - a[2]]
    return np.cross(a, b)


def drawsq():
    global size, delta_x, delta_y, delta_z
    '''global speed
    delta_x += speed * direction[0]
    delta_y += speed * direction[1]
    delta_z += speed * direction[2]
    speed -= 0.0005 * direction[1]
    if abs(delta_x) >= 1:
        direction[0] = -direction[0]
    if abs(delta_y) >= 1:
        direction[1] = -direction[1]
    if abs(delta_z) >= 1:
        direction[2] = -direction[2]
    else:
        speed -= 0.0005 * direction[1]'''
    global vertices, normals, indices, display_list

    display_list = glGenLists(1)
    glNewList(display_list, GL_COMPILE)

    for j in range(1, n):
        i = 0
        glBegin(GL_QUAD_STRIP)
        while i <= 2 * math.pi:
            m = size - j / n * size
            m_pred = size - (j - 1) / n * size
            x = m * math.cos(i) * math.cos(j / n) + delta_x
            x_pred = m_pred * math.cos(i) * math.cos((j - 1) / n) + delta_x
            y = m * math.sin(i) * math.cos(j / n) + delta_y
            y_pred = m_pred * math.sin(i) * math.cos((j - 1) / n) + delta_y
            z = j / n + delta_z
            z_pred = (j - 1) / n + delta_z
            glColor3f(1, 1, 1)
            norm = getnorm([x_pred, y_pred, (j - 1 / n)], [x, y, j / n],
                           [m * math.cos(i + math.pi / 2) * math.cos(j / n),
                            m * math.sin(i + math.pi / 2) * math.cos(j / n), j / n])
            glNormal3d(norm[0], norm[1], norm[2])
            glTexCoord2f(i / (2 * math.pi), 1)

            glVertex3f(x, y, z)
            glTexCoord2f(0, i / (2 * math.pi))
            glVertex3f(x_pred, y_pred, z_pred)

            i += math.pi / 2
        glEnd()
    glEndList()

vertices = []


def create_vbo():
    global vbo

    for j in range(1, n):
        i = 0
        while i <= 2 * math.pi:
            m = size - j / n * size
            m_pred = size - (j - 1) / n * size
            x = m * math.cos(i) * math.cos(j / n) + delta_x
            x_pred = m_pred * math.cos(i) * math.cos((j - 1) / n) + delta_x
            y = m * math.sin(i) * math.cos(j / n) + delta_y
            y_pred = m_pred * math.sin(i) * math.cos((j - 1) / n) + delta_y
            z = j / n + delta_z
            z_pred = (j - 1) / n + delta_z
            norm = getnorm([x_pred, y_pred, (j - 1 / n)], [x, y, j / n],
                           [m * math.cos(i + math.pi / 2) * math.cos(j / n),
                            m * math.sin(i + math.pi / 2) * math.cos(j / n), j / n])
            glNormal3d(norm[0], norm[1], norm[2])
            vertices.extend([x, y, z])
            vertices.extend([x_pred, y_pred, z_pred])
            i += math.pi / 2
    vbo = glGenBuffers(1)
    glBindBuffer(GL_ARRAY_BUFFER, vbo)
    glBufferData(GL_ARRAY_BUFFER, np.array(vertices, dtype=np.float32), GL_STATIC_DRAW)


def draw_with_vbo():
    glBindBuffer(GL_ARRAY_BUFFER, vbo)
    glEnableClientState(GL_VERTEX_ARRAY)
    glVertexPointer(3, GL_FLOAT, 0, None)
    glDrawArrays(GL_QUAD_STRIP, 0, int(len(vertices) / 2))
    glDisableClientState(GL_VERTEX_ARRAY)

def display(window):
    global size, delta_x, delta_y, delta_z, display_list
    glEnable(GL_TEXTURE_2D)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    material_diffuse = [0, 0, 0., 0.]
    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, material_diffuse)
    glBindTexture(GL_TEXTURE_2D, texture)

    light2_diffuse = [0.4, 0.7, .1]
    light2_position = [0, 0.25, 1, 3]
    light2_attenuation = [1.0, 0.01, 0.032]

    glLightfv(GL_LIGHT2, GL_DIFFUSE, light2_diffuse)
    glLightfv(GL_LIGHT2, GL_POSITION, light2_position)
    glLightfv(GL_LIGHT2, GL_CONSTANT_ATTENUATION, light2_attenuation[0])
    glLightfv(GL_LIGHT2, GL_LINEAR_ATTENUATION, light2_attenuation[1])
    glLightfv(GL_LIGHT2, GL_QUADRATIC_ATTENUATION, light2_attenuation[2])
    glLightfv(GL_LIGHT2, GL_SPOT_DIRECTION, [0, 0, -1])

    glPointSize(5)
    glBegin(GL_QUADS)
    glColor3f(1, 1, 1)

    glTexCoord2f(0, 1)
    glNormal3f(0., 1.1, .0, )
    glVertex3f(-0.7, -0.6, 0.)

    glTexCoord2f(1, 1)
    glVertex3f(0.7, -0.6, 0.)

    glTexCoord2f(1, 0)
    glVertex3f(0.7, 1., .0)

    glTexCoord2f(0, 0)
    glVertex3f(-0.7, 1., .0)

    glEnd()
    glCallList(display_list)
    draw_with_vbo()
    glDisable(GL_TEXTURE_2D)
    if flag:
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
    else:
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
    glPushMatrix()
    glRotatef(angle2, 1, 0, 0)
    glRotate(angle, 0, 0, 1)
    glPushMatrix()
    glPopMatrix()
    glPopMatrix()

    count_fps()

    glfw.swap_buffers(window)
    glfw.poll_events()


def key_callback(window, key, scancode, action, mods):
    global angle, angle2, flag
    if action == glfw.PRESS:
        if key == glfw.KEY_SPACE:
            flag = not flag


def scroll_callback(window, xoffset, yoffset):
    global size
    if xoffset > 0:
        size -= yoffset / 10
    else:
        size += yoffset / 10


def main():
    if not glfw.init():
        return
    window = glfw.create_window(800, 800, "Lab7", None, None)
    if not window:
        glfw.terminate()
        return
    glfw.make_context_current(window)
    glfw.set_key_callback(window, key_callback)
    glfw.set_scroll_callback(window, scroll_callback)
    glClearColor(0.0, 0.0, 0.0, 0.0)
    glLightModelf(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE)
    glEnable(GL_LIGHTING)
    glEnable(GL_COLOR_MATERIAL)
    glEnable(GL_LIGHT0)
    glEnable(GL_LIGHT1)
    glEnable(GL_LIGHT2)
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    glOrtho(-1.2, 1.2, -1.2, 1.2, -1, 1)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()
    glEnable(GL_DEPTH_TEST)
    glGenTextures(1, texture)
    glBindTexture(GL_TEXTURE_2D, texture)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, np.array(list(im.getdata()), np.uint8))
    glBindTexture(GL_TEXTURE_2D, 0)

    drawsq()
    create_vbo()
    while not glfw.window_should_close(window):
        glfw.poll_events()
        display(window)
    with open('optimization.csv', 'w') as file:
        csv.writer(file, delimiter=' ').writerows(fps_list)

    glfw.terminate()

if __name__ == "__main__":
    main()