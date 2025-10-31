data = {
    entities = {
        
        -- player
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        [16] = {
            class = "player",
        },


        -- pets
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        [19] = {
            class = "pet",
            name = "cat",
        },

        [20] = {
            class = "pet",
            name = "dog",
        },


        -- npcs
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        [17] = {
            class = "npc",
            name = "green guy",
        },

        [18] = {
            class = "npc",
            name = "dinosaur",
        },

        [21] = {
            class = "npc",
            name = "man",
        },


        -- enemies
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        [22] = {
            class = "npc",
            name = "blob",
        },

        [23] = {
            class = "npc",
            name = "hobgoblin",
        },

        [24] = {
            class = "enemy",
            name = "skully",
        },

        [25] = {
            class = "npc",
            name = "ghoul",
        },

        [26] = {
            class = "npc",
            name = "bat",
        },

        [27] = {
            class = "npc",
            name = "vampire",
        },


        -- interactables
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        [3] = {
            class = "sign",
            name = "grave", 
        },

        [5] = {
            class = "interactable",
            name = "stairs",
            collision = false,

        },

        [6] = {
            class = "interactable",
            name = "stairs",
            collision = false,

        },

        [7] = {
            class = "interactable",
            name = "stairs",
            collision = false,
        },

        [8] = {
            class = "interactable",
            name = "stairs",
            collision = false,
        },

        [4] = {
            class = "sign",
            name = "sign",
        },

        [51] = {
            class = "interactable",
            name = "chest",
        },

        [52] = {
            class = "interactable",
            name = "locked door",
        },

        [53] = {
            class = "interactable",
            name = "locked door",
        },

        [81] = {
            class = "door",
            name = "door",
            collision = false,
        },

        [82] = {
            class = "door",
            name = "door",
        },


        -- items
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        [54] = {
            class = "item",
            name = "key",
        },

        [55] = {
            class = "item",
            name = "gold key",
        },

        [56] = {
            class = "item",
            name = "bomb",
        },

        [57] = {
            class = "item",
            name = "sword",
        },

        [58] = {
            class = "item",
            name = "bow",
        },

        [59] = {
            class = "item",
            name = "potion",
        },

        [60] = {
            class = "item",
            name = "potion",
        },

    },
    signs = {
        {
            x=6,
            y=22,
            message="hello there\nthis is a sign"
        }
    }
}
