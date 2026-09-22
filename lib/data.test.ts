import { describe, expect, it } from "vitest";
import { getItems } from "./data";

describe("getItems", () => {
  it("returns exactly 3 items with id and label", () => {
    const items = getItems();

    expect(items.length).toBe(3);
    for (const item of items) {
      expect(typeof item.id).toBe("string");
      expect(typeof item.label).toBe("string");
    }
  });
});
