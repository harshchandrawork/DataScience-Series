import json, os


class Database:
    def __init__(self):
        if not os.path.exists("users.json"):
            with open("users.json", "w") as wf:
                json.dump({}, wf)

    def insert(self, name, email, password):
        with open("users.json", "r") as rf:
            users = json.load(rf)

        if email in users:
            return ()
        else:
            users[email] = [name, password]

        with open("users.json", "w") as wf:
            json.dump(users, wf, indent=4)
            return 1

    def search(self, email, password):
        with open("users.json", "r") as rf:
            users = json.load(rf)

            if email in users:
                if users[email][1] == password:
                    return 1
                else:
                    return 0
            else:
                return 0
