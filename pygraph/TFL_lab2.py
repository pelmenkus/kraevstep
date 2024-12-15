import subprocess
import json


class LispGuesser:
    def __init__(self, filepath, parameters_path):
        # Чтение параметров из файла
        self.parameters = self.load_parameters(parameters_path)
        self.max_bracket_depth = self.parameters["max_bracket_depth"]
        self.max_automaton_size = self.parameters["max_automaton_size"]

        self.alphabet = "0123456789() ."
        self.S = [""]
        self.E = [""]
        self.mat_process = subprocess.Popen(
            ["python3", filepath],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            text=True
        )
        self.table = {("", ""): self.membership_query("")}

    @staticmethod
    def load_parameters(filepath):
        """Чтение параметров из файла."""
        with open(filepath, "r") as f:
            return json.load(f)

    def membership_query(self, word):
        """Запрос включения: проверяет, принадлежит ли строка языку."""
        if self.validate_word(word):
            self.mat_process.stdin.write("isin\n")
            self.mat_process.stdin.write(f"{word}\n")
            self.mat_process.stdin.flush()
            result = self.mat_process.stdout.readline().strip()
            return result == "True"
        return False

    def equivalence_query(self, hypothesis):
        """Запрос эквивалентности: проверяет, эквивалентна ли гипотеза целевому автомату."""
        self.mat_process.stdin.write("equal\n")
        self.mat_process.stdin.write(f"{hypothesis}\n")
        self.mat_process.stdin.write("end\n")
        self.mat_process.stdin.flush()
        result = self.mat_process.stdout.readline().strip()
        if result == "TRUE":
            return True, None
        return False, result

    def validate_word(self, word):
        """Проверяет корректность слова по грамматике и ограничению вложенности скобок."""
        depth = 0
        for char in word:
            if char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
                if depth < 0:
                    return False
        return depth == 0 and depth <= self.max_bracket_depth

    def process_counterexample(self, counterexample):
        """Обработка контрпримера: обновляет S и E."""
        for i in range(1, len(counterexample) + 1):
            prefix = counterexample[:i]
            if prefix not in self.S:
                self.S.append(prefix)

        for i in range(len(counterexample)):
            suffix = counterexample[i:]
            if suffix not in self.E:
                self.E.append(suffix)

    def build_hypothesis(self):
        """Строит гипотезу на основе текущей таблицы."""
        states = {s: i for i, s in enumerate(self.S)}
        transitions = {}
        for s in self.S:
            for a in self.alphabet:
                next_state = s + a
                if next_state in self.S:
                    transitions[(states[s], a)] = states[next_state]
        return {
            "states": set(states.values()),
            "transitions": transitions,
            "accept_states": {s for s in self.S if self.table.get((s, ""), False)},
        }

    def run(self):
        """Основной цикл угадывания."""
        while True:
            self.close_table()

            # Строим гипотезу и отправляем на проверку
            hypothesis = self.build_hypothesis()
            equivalent, counterexample = self.equivalence_query(hypothesis)

            if equivalent:
                print("Гипотеза верна! Автомат построен.")
                break
            else:
                print("Получен контрпример:", counterexample)
                self.process_counterexample(counterexample)
                self.update_table()

    def close_table(self):
        """Удостоверяемся, что таблица эквивалентности полная."""
        while True:
            for s in self.S:
                for a in self.alphabet:
                    sa = s + a
                    if sa not in self.S:
                        self.S.append(sa)
                        self.update_table()
                        return
            break

    def update_table(self):
        """Обновляет таблицу эквивалентности."""
        for s in self.S:
            for e in self.E:
                if (s, e) not in self.table:
                    self.table[(s, e)] = self.membership_query(s + e)

    def close(self):
        """Закрывает процесс MAT."""
        self.mat_process.terminate()


def main():
    guesser = LispGuesser("MAT/tfl-lab2/main.py", "parameters.txt")
    guesser.run()
    guesser.close()


if __name__ == "__main__":
    main()
