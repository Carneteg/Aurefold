/*
 * AUREFOLD — the Ten Great Houses.
 * Canon data for the interactive map (map.html). Do not add houses, people,
 * or lore here that is not established canon.
 *
 * Public-safe: named house heads/heirs are intentionally NOT listed here (they
 * are held back until the book is published, matching houses.html/characters.html).
 * Each house shows its philosophy and its promise/cost line; a spoiler-safe
 * Book One note is added only where it is public-safe.
 *
 * coords are positions on the map chart (viewBox 1200 x 900).
 * Loaded as a plain script so the site works when opened directly from disk.
 */
window.AUREFOLD_HOUSES = [
  {
    id: "blackthorn",
    name: "House Blackthorn",
    philosophy: "Intellect",
    seat: "Thorn Hall",
    region: "the Thornland (S)",
    line: "The planner who always acts too late, and the daughter who would act now.",
    coords: { x: 590, y: 700 },
  },
  {
    id: "ravenshade",
    name: "House Ravenshade",
    philosophy: "Information",
    seat: "Duskport",
    region: "the Sleep Coast (W)",
    line: "All their power is borrowed, and the patron it is borrowed from is failing.",
    coords: { x: 285, y: 468 },
  },
  {
    id: "ashbourne",
    name: "House Ashbourne",
    philosophy: "Courage",
    seat: "Dawnwatch",
    region: "the Edgelands (E)",
    line: "The old rider doubts what the Wall of Names cost; the young one dreams of a Leap no rider survives.",
    coords: { x: 940, y: 430 },
  },
  {
    id: "whitehart",
    name: "House Whitehart",
    philosophy: "Faith",
    seat: "The Bell of Silence",
    region: "the Light Heights (NW)",
    line: "A house that listens for a voice, and tests those who claim to hear it.",
    note: "In Book One: the testing of the goatherd Sela, and Brother Tomas's first doubt.",
    coords: { x: 355, y: 240 },
  },
  {
    id: "stormrider",
    name: "House Stormrider",
    philosophy: "Unity",
    seat: "The Hub",
    region: "northern rim of the Ash Fields",
    line: "Unity holds only as long as the uniter lives, and the Binder is dying.",
    coords: { x: 600, y: 312 },
  },
  {
    id: "ironvale",
    name: "House Ironvale",
    philosophy: "Innovation",
    seat: "Forge Gap",
    region: "the Ore Valleys (SE)",
    line: "They measured everything in the realm; one event at their own forge would not be measured.",
    coords: { x: 845, y: 612 },
  },
  {
    id: "blackcrest",
    name: "House Blackcrest",
    philosophy: "The victor’s history",
    seat: "Crown-watch",
    region: "edge of the Ash Fields",
    line: "Keepers of the Chronicle of Victory: the realm despises them, and every house has quietly been their client.",
    note: "In Book One: a chronicler comes to the valley, gathering testimony for the coming jubilee.",
    coords: { x: 758, y: 452 },
  },
  {
    id: "stonebear",
    name: "House Stonebear",
    philosophy: "Honor",
    seat: "Oath-hold",
    region: "foot of the Silent Mountains (NE)",
    line: "A house being bankrupted by its own kept word, led by a man entirely at peace with the cost.",
    coords: { x: 830, y: 222 },
  },
  {
    id: "tidebreaker",
    name: "House Tidebreaker",
    philosophy: "Knowledge",
    seat: "The Wave-Reader",
    region: "the Shards (S islands)",
    line: "Charts of everything, shared with no one; their lighthouse shines out over the empty sea.",
    coords: { x: 522, y: 838 },
  },
  {
    id: "phoenix",
    name: "House Phoenix",
    philosophy: "The future",
    seat: "New-Ash",
    region: "the Burnt Road",
    line: "A house built on scorched ground that refuses, on principle, to look down.",
    coords: { x: 452, y: 556 },
  },
];
