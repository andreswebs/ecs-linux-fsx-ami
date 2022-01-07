# credits:
# https://stackoverflow.com/a/68405519/8523668

def python_type(s):
    return type(s)

class FilterModule(object):
    def filters(self):
        return {
            'python_type': python_type,
        }