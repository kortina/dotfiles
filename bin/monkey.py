#!/usr/bin/env python
import types


class Rect(object):
    def __init__(self, width, height):
        self.width = width
        self.height = height

    def __repr__(self):
        return f"Rect <width: {self.width}, height: {self.height}>"

    def __str__(self):
        return f"Rect <width: {self.width}, height: {self.height}>"

    @classmethod
    def orig_classmethod(cls):
        print("orig_classmethod")

    def area(self):
        print(f"self.area {self}")
        return self.width * self.height


_area = Rect.area


def _monkey(self):
    print(f"_monkey {self}: ", end="")
    return _area(self)


a = Rect(1, 2)
b = Rect(3, 4)
# only patch for 'a'
a.area = types.MethodType(_monkey, a)
a.area()
# _monkey Rect <width: 1, height: 2>: self.area Rect <width: 1, height: 2>
b.area()
# self.area Rect <width: 3, height: 4>

# patch for all instances of Rect
Rect.area = _monkey
c = Rect(5, 6)
# _monkey Rect <width: 5, height: 6>: self.area Rect <width: 5, height: 6>
d = Rect(7, 8)
# _monkey Rect <width: 7, height: 8>: self.area Rect <width: 7, height: 8>

c.area()
d.area()
