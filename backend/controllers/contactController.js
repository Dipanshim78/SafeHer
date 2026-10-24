// const Contact = require("../models/Contact");

// exports.addContact = async (req, res) => {//runs when user add a new contact
// const { name, phone, email } = req.body || {};
//   const normalizedName = typeof name === "string" ? name.trim() : "";
//   const normalizedPhone = typeof phone === "string" ? phone.trim() : "";
//   const normalizedEmail = typeof email === "string" ? email.trim().toLowerCase() : "";

//   // if (!normalizedName || !/^\+[1-9]\d{6,14}$/.test(normalizedPhone)) {
//   if (
//   !normalizedName ||
//   !/^\+[1-9]\d{6,14}$/.test(normalizedPhone) ||
//   !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalizedEmail)
// ) {
//     return res.status(400).json({
//  msg: "Enter a contact name, valid phone number with country code, and valid email address",
//     });
//   }

//   // const contact = new Contact({
//   //   userId: req.user.id,///IMPORTANT (links contacts to the logged-in-user)(means every user have their own contact list)
//   //   name: normalizedName,
//   //   phone: normalizedPhone,
//   // });
//   const contact = new Contact({
//   userId: req.user.id,
//   name: normalizedName,
//   phone: normalizedPhone,
//   email: normalizedEmail,
// });

//   try {
//     await contact.save();
//     res.status(201).json({ msg: "Contact added" });
//   } catch (err) {
//     if (err.code === 11000) {
//       return res.status(409).json({ msg: "This contact is already saved" });
//     }
//     throw err;
//   }
// };

// exports.getContacts = async (req, res) => {//runs when user wants to see saved contacts
//   const contacts = await Contact.find({ userId: req.user.id });////(fetches only those contacts belongs to that user)
//   res.json(contacts);//sends contact list to fronted
// };
// exports.updateContact = async (req, res) => {
//   const { name, phone, email } = req.body || {};

//   const normalizedName =
//     typeof name === "string" ? name.trim() : "";

//   const normalizedPhone =
//     typeof phone === "string" ? phone.trim() : "";

//   const normalizedEmail =
//     typeof email === "string"
//       ? email.trim().toLowerCase()
//       : "";

//   if (
//     !normalizedName ||
//     !/^\+[1-9]\d{6,14}$/.test(normalizedPhone) ||
//     !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalizedEmail)
//   ) {
//     return res.status(400).json({
//       msg: "Enter a contact name, valid phone number with country code, and valid email address",
//     });
//   }

//   try {
//     const contact = await Contact.findOneAndUpdate(
//       {
//         _id: req.params.id,
//         userId: req.user.id,
//       },
//       {
//         name: normalizedName,
//         phone: normalizedPhone,
//         email: normalizedEmail,
//       },
//       { new: true }
//     );

//     if (!contact) {
//       return res.status(404).json({
//         msg: "Contact not found",
//       });
//     }

//     res.json({
//       msg: "Contact updated",
//       contact,
//     });
//   } catch (err) {
//     if (err.code === 11000) {
//       return res.status(409).json({
//         msg: "This phone number is already saved",
//       });
//     }

//     console.error("Update contact failed:", err.message);

//     res.status(500).json({
//       msg: "Error updating contact",
//     });
//   }
// };
// exports.deleteContact = async (req, res) => {
//   try {
//     const contact = await Contact.findOneAndDelete({
//       _id: req.params.id,
//       userId: req.user.id,
//     });

//     if (!contact) {
//       return res.status(404).json({
//         msg: "Contact not found",
//       });
//     }

//     res.json({
//       msg: "Contact deleted",
//     });
//   } catch (err) {
//     console.error("Delete contact failed:", err.message);

//     res.status(500).json({
//       msg: "Error deleting contact",
//     });
//   }
// };
const Contact = require("../models/Contact");

exports.addContact = async (req, res) => {
  const { name, phone, email } = req.body || {};

  const normalizedName =
    typeof name === "string" ? name.trim() : "";

  const normalizedPhone =
    typeof phone === "string" ? phone.trim() : "";

  const normalizedEmail =
    typeof email === "string"
      ? email.trim().toLowerCase()
      : "";

  // Name is required and at least one contact method is required
  if (
    !normalizedName ||
    (normalizedPhone === "" && normalizedEmail === "")
  ) {
    return res.status(400).json({
      msg: "Enter a contact name and at least a phone number or email address",
    });
  }

  // Validate phone only when provided
  if (
    normalizedPhone &&
    !/^\+[1-9]\d{6,14}$/.test(normalizedPhone)
  ) {
    return res.status(400).json({
      msg: "Enter a valid phone number with country code",
    });
  }

  // Validate email only when provided
  if (
    normalizedEmail &&
    !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalizedEmail)
  ) {
    return res.status(400).json({
      msg: "Enter a valid email address",
    });
  }

  const contact = new Contact({
    userId: req.user.id,
    name: normalizedName,
    phone: normalizedPhone,
    email: normalizedEmail,
  });

  try {
    await contact.save();

    res.status(201).json({
      msg: "Contact added",
      contact,
    });
  } catch (err) {
    if (err.code === 11000) {
      return res.status(409).json({
        msg: "This contact is already saved",
      });
    }

    console.error("Add contact failed:", err.message);

    res.status(500).json({
      msg: "Error adding contact",
    });
  }
};


exports.getContacts = async (req, res) => {
  try {
    const contacts = await Contact.find({
      userId: req.user.id,
    });

    res.json(contacts);
  } catch (err) {
    console.error("Get contacts failed:", err.message);

    res.status(500).json({
      msg: "Error fetching contacts",
    });
  }
};


exports.updateContact = async (req, res) => {
  const { name, phone, email } = req.body || {};

  const normalizedName =
    typeof name === "string" ? name.trim() : "";

  const normalizedPhone =
    typeof phone === "string" ? phone.trim() : "";

  const normalizedEmail =
    typeof email === "string"
      ? email.trim().toLowerCase()
      : "";

  // Name is required and at least one contact method is required
  if (
    !normalizedName ||
    (normalizedPhone === "" && normalizedEmail === "")
  ) {
    return res.status(400).json({
      msg: "Enter a contact name and at least a phone number or email address",
    });
  }

  // Validate phone only when provided
  if (
    normalizedPhone &&
    !/^\+[1-9]\d{6,14}$/.test(normalizedPhone)
  ) {
    return res.status(400).json({
      msg: "Enter a valid phone number with country code",
    });
  }

  // Validate email only when provided
  if (
    normalizedEmail &&
    !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalizedEmail)
  ) {
    return res.status(400).json({
      msg: "Enter a valid email address",
    });
  }

  try {
    const contact = await Contact.findOneAndUpdate(
      {
        _id: req.params.id,
        userId: req.user.id,
      },
      {
        name: normalizedName,
        phone: normalizedPhone,
        email: normalizedEmail,
      },
      {
        new: true,
      }
    );

    if (!contact) {
      return res.status(404).json({
        msg: "Contact not found",
      });
    }

    res.json({
      msg: "Contact updated",
      contact,
    });
  } catch (err) {
    if (err.code === 11000) {
      return res.status(409).json({
        msg: "This phone number is already saved",
      });
    }

    console.error("Update contact failed:", err.message);

    res.status(500).json({
      msg: "Error updating contact",
    });
  }
};


exports.deleteContact = async (req, res) => {
  try {
    const contact = await Contact.findOneAndDelete({
      _id: req.params.id,
      userId: req.user.id,
    });

    if (!contact) {
      return res.status(404).json({
        msg: "Contact not found",
      });
    }

    res.json({
      msg: "Contact deleted",
    });
  } catch (err) {
    console.error("Delete contact failed:", err.message);

    res.status(500).json({
      msg: "Error deleting contact",
    });
  }
};