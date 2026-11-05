import time
from collections import OrderedDict

class LRUCache:
    def __init__(self, capacity, ttl=None, clock=time.monotonic):
        if capacity <= 0: raise ValueError("capacity")
        if ttl is not None and ttl <= 0: raise ValueError("ttl")
        self.capacity, self.ttl, self.clock = capacity, ttl, clock
        self._d = OrderedDict()
        self._s = {"hits": 0, "misses": 0, "evictions": 0, "expirations": 0}
    def _dead(self, k):
        e = self._d[k][1]
        return e is not None and self.clock() >= e
    def put(self, key, value, ttl=None):
        if ttl is not None and ttl <= 0: raise ValueError("ttl")
        t = ttl if ttl is not None else self.ttl
        if key in self._d: del self._d[key]
        elif len(self._d) >= self.capacity:
            self.purge()
            if len(self._d) >= self.capacity:
                self._d.popitem(last=False); self._s["evictions"] += 1
        self._d[key] = (value, None if t is None else self.clock() + t)
    def get(self, key, default=None):
        if key in self._d and self._dead(key):
            del self._d[key]; self._s["expirations"] += 1
        if key not in self._d:
            self._s["misses"] += 1; return default
        self._d.move_to_end(key); self._s["hits"] += 1
        return self._d[key][0]
    def delete(self, key):
        if key in self._d and not self._dead(key):
            del self._d[key]; return True
        return False
    def purge(self):
        dead = [k for k in self._d if self._dead(k)]
        for k in dead: del self._d[k]
        self._s["expirations"] += len(dead)
        return len(dead)
    def keys(self): return [k for k in self._d if not self._dead(k)]
    def __len__(self): return len(self.keys())
    def __contains__(self, key): return key in self._d and not self._dead(key)
    def stats(self): return dict(self._s)
