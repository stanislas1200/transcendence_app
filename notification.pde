public class notification {
	String message;
	int x, y;
	int boxWidth, boxHeight;
	int timeout;
	boolean visible;

	public notification(String message, int x, int y, int boxWidth, int boxHeight, int timeout) {
		this.message = message;
		this.x = x;
		this.y = y;
		this.boxWidth = boxWidth;
		this.boxHeight = boxHeight;
		this.timeout = timeout * 60;
		this.visible = true;
	}

	public void display() {
		if (visible) {
      // Box
      push();
      fill(colors[3]);
      rectMode(CENTER);
      stroke(colors[3]);
      strokeWeight(10);
      strokeJoin(ROUND);
      rect(x, y, boxWidth, boxHeight);
      
      // Text
      fill(colors[0]);
      textSize(30);
      textAlign(CENTER, CENTER);
      text(message, x, y);
      pop();
			if (timeout > 0) {
				timeout--;
				if (timeout == 0) {
					visible = false;
				}
			}
		}
	}
}
