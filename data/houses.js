/*
 * AUREFOLD — the Ten Great Houses.
 * Canon data for the interactive map (map.html). Do not add houses, people,
 * or lore here that is not established canon.
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
    people: [
      { role: "Head", name: "Alder Blackthorn" },
      { role: "Heir", name: "Wren Blackthorn" },
    ],
    line: "The planner who always acts too late, and the daughter who would act now.",
    coords: { x: 590, y: 700 },
  },
  {
    id: "ravenshade",
    name: "House Ravenshade",
    philosophy: "Information",
    seat: "Duskport",
    region: "the Sleep Coast (W)",
    people: [
      { role: "Head", name: "Sabra Ravenshade" },
      { role: "Heir", name: "Lyra Ravenshade" },
    ],
    line: "All their power is borrowed, and the patron it is borrowed from is failing.",
    coords: { x: 285, y: 468 },
  },
  {
    id: "ashbourne",
    name: "House Ashbourne",
    philosophy: "Courage",
    seat: "Dawnwatch",
    region: "the Edgelands (E)",
    people: [
      { role: "Head", name: "Roderick Ashbourne" },
      { role: "Heir", name: "Kael Ashbourne" },
    ],
    line: "The old rider doubts what the Wall of Names cost; the young one dreams of a Leap no rider survives.",
    coords: { x: 940, y: 430 },
  },
  {
    id: "whitehart",
    name: "House Whitehart",
    philosophy: "Faith",
    seat: "The Bell of Silence",
    region: "the Light Heights (NW)",
    people: [
      { role: "Head", name: "Mother Alaine" },
      { role: "Key figures", name: "Sela (the Called), Brother Tomas (the Tester)" },
    ],
    line: "A house that listens for a voice, and tests those who claim to hear it.",
    coords: { x: 355, y: 240 },
  },
  {
    id: "stormrider",
    name: "House Stormrider",
    philosophy: "Unity",
    seat: "The Hub",
    region: "northern rim of the Ash Fields",
    people: [
      { role: "Head", name: "Garron, the Binder" },
      { role: "Key figures", name: "Una, Orrin, Katla" },
    ],
    line: "Unity holds only as long as the uniter lives, and the Binder is dying.",
    coords: { x: 600, y: 312 },
  },
  {
    id: "ironvale",
    name: "House Ironvale",
    philosophy: "Innovation",
    seat: "Forge Gap",
    region: "the Ore Valleys (SE)",
    people: [
      { role: "Head", name: "Master Halvard" },
      { role: "Heir", name: "Senna Ironvale" },
    ],
    line: "They measured everything in the realm; one event at their own forge would not be measured.",
    coords: { x: 845, y: 612 },
  },
  {
    id: "blackcrest",
    name: "House Blackcrest",
    philosophy: "The victor’s history",
    seat: "Crown-watch",
    region: "edge of the Ash Fields",
    people: [
      { role: "Head", name: "Aldous Blackcrest" },
      { role: "Heir", name: "Vaela Blackcrest" },
    ],
    line: "Keepers of the Chronicle of Victory: the realm despises them, and every house has quietly been their client.",
    coords: { x: 758, y: 452 },
  },
  {
    id: "stonebear",
    name: "House Stonebear",
    philosophy: "Honor",
    seat: "Oath-hold",
    region: "foot of the Silent Mountains (NE)",
    people: [
      { role: "Head", name: "Reverend Torvald" },
      { role: "Heir", name: "Rurik Stonebear" },
    ],
    line: "A house being bankrupted by its own kept word, led by a man entirely at peace with the cost.",
    coords: { x: 830, y: 222 },
  },
  {
    id: "tidebreaker",
    name: "House Tidebreaker",
    philosophy: "Knowledge",
    seat: "The Wave-Reader",
    region: "the Shards (S islands)",
    people: [
      { role: "Head", name: "Maren Tidebreaker" },
      { role: "Heir", name: "Espen Tidebreaker" },
    ],
    line: "Charts of everything, shared with no one; their lighthouse shines out over the empty sea.",
    coords: { x: 522, y: 838 },
  },
  {
    id: "phoenix",
    name: "House Phoenix",
    philosophy: "The future",
    seat: "New-Ash",
    region: "the Burnt Road",
    people: [
      { role: "Head", name: "Signe Phoenix" },
      { role: "Heir", name: "Idun Phoenix" },
    ],
    line: "A house built on scorched ground that refuses, on principle, to look down.",
    coords: { x: 452, y: 556 },
  },
];
