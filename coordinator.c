#include <Entropy.h>
#include <Bounce2.h>

const int a_base = 1; # Starting pin for each player's green led/button
const int b_base = 14; # Starting pin for each player's red led/button
const int led = 13; # debug led
const int big_switch = 0; # Control of the relay
const int control = 11; # Coodinator button
Bounce debouncer = Bounce();

char player_state[10] = {0};
char player_active[10] = {0};

int votes_required = 0;

void sleep(int m) {
  if (m == 0) return;
  digitalWrite(led, HIGH);
  delay(m);
  digitalWrite(led, LOW);
}

void readMode() {
  pinMode(big_switch, OUTPUT);
  digitalWrite(big_switch, LOW);
  sleep(70);

  for (int i = 0; i < 10; i++) {
    pinMode(a_base + i, INPUT_PULLUP);
    pinMode(b_base + i, INPUT_PULLUP);
    player_state[i] = 0;
  }
}

void ledMode() {
  pinMode(big_switch, INPUT);
  sleep(70);

  for (int i = 0; i < 10; i++) {
    if (player_state[i] == 1) {
      pinMode(a_base + i, OUTPUT);
      digitalWrite(a_base + i, LOW);
    }

    if (player_state[i] == 2) {
      pinMode(b_base + i, OUTPUT);
      digitalWrite(b_base + i, LOW);
    }
  }
}

void setup() {
  pinMode(control, INPUT_PULLUP);
  debouncer.attach(control);
  debouncer.interval(10);

  pinMode(led, OUTPUT);
  Entropy.Initialize();
  randomSeed(Entropy.random());

  digitalWrite(led, LOW);
  readMode();
}

void readPlayerButtons() {
  for (int i = 0; i < 10; i++) {
    if (digitalRead(a_base + i) == LOW) {
      player_state[i] = 1;
    }

    if (digitalRead(b_base + i) == LOW) {
      player_state[i] = 2;
    }
  }
}

// 0 - player init
// 1 - showing leds
// 2 - vote
int state = 0;

void player_init() {
  readPlayerButtons();
  if (!debouncer.fell()) {
    return;
  }

  for (int i = 0; i < 10; i++) {
    player_active[i] = player_state[i] > 0 ? 1 : 0;
    player_state[i] = player_active[i];
  }

  ledMode();
  state = 1;
}

void show_leds() {
  if (!debouncer.fell()) {
    return;
  }

  for (int i = 0; i < 10; i++) {
    player_state[i] = 0;
  }

  readMode();
  state = 2;

  votes_required = 1;
}

void vote() {
  readPlayerButtons();
  if (debouncer.fell()) {
    votes_required++;
  }

  if (votes_required == 1) {
    // If everyone has voted, show the results
    for (int i = 0; i < 10; i++) {
      if (player_active[i] && player_state[i] == 0) {
        return;
      }
    }
  } else {
    int voted = 0;

    for (int i = 0; i < 10; i++) {
      if (player_state[i] != 0) {
        voted++;
      }
    }

    if (voted < votes_required) {
      return;
    }

    // This was an anonymous vote, shuffle the current votes and show them
    char tmp[10] = {0};
    int j = 0;

    for (int i = 0; i < 10; i++) {
      if (player_state[i] != 0) {
        tmp[j++] = player_state[i];
      }
    }

    for (int i = 0; i < j; i++) {
      int idx = random(i, j);
      char t = tmp[idx];
      tmp[idx] = tmp[i];
      tmp[i] = t;
    }

    for (int i = 0; i < 10; i++) {
      if (player_state[i] != 0) {
        player_state[i] = tmp[--j];
      }
    }
  }

  ledMode();
  state = 1;
}

void loop() {
  debouncer.update();

  if (state == 0) {
    player_init();
  } else if (state == 1) {
    show_leds();
  } else if (state == 2) {
    vote();
  }
}
