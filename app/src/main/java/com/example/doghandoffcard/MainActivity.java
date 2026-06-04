package com.example.doghandoffcard;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.text.InputType;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

public final class MainActivity extends Activity {
    private EditText dogNameField;
    private EditText ageField;
    private EditText breedField;
    private EditText feedingField;
    private EditText walksField;
    private EditText medicationNameField;
    private EditText medicationDoseField;
    private EditText medicationTimeField;
    private EditText missedDoseField;
    private EditText ownerPhoneField;
    private EditText clinicPhoneField;
    private EditText caregiverField;
    private TextView readinessOutput;
    private TextView cardOutput;
    private Button shareButton;
    private String latestPlainText = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ScrollView scrollView = new ScrollView(this);
        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setPadding(32, 32, 32, 32);
        scrollView.addView(content);

        TextView title = new TextView(this);
        title.setText("DogHandoffCard");
        title.setTextSize(28);
        title.setTextColor(Color.rgb(40, 40, 40));
        content.addView(title);

        TextView intro = new TextView(this);
        intro.setText("Create a caregiver-ready Android handoff card for a senior dog.");
        intro.setTextSize(16);
        intro.setPadding(0, 8, 0, 24);
        content.addView(intro);

        dogNameField = addField(content, "Dog name");
        ageField = addField(content, "Age");
        breedField = addField(content, "Breed");
        feedingField = addMultilineField(content, "Feeding instructions");
        walksField = addField(content, "Walk frequency");
        medicationNameField = addField(content, "Medication name");
        medicationDoseField = addField(content, "Medication dose");
        medicationTimeField = addField(content, "Medication time, for example 08:00,20:00");
        missedDoseField = addMultilineField(content, "Missed-dose instruction");
        ownerPhoneField = addField(content, "Owner phone");
        clinicPhoneField = addField(content, "Clinic phone");
        caregiverField = addField(content, "Caregiver name");

        Button sampleButton = new Button(this);
        sampleButton.setText("Load sample data");
        sampleButton.setOnClickListener(view -> loadSampleData());
        content.addView(sampleButton);

        Button buildButton = new Button(this);
        buildButton.setText("Build handoff card");
        buildButton.setOnClickListener(view -> buildCard());
        content.addView(buildButton);

        shareButton = new Button(this);
        shareButton.setText("Share plain text");
        shareButton.setEnabled(false);
        shareButton.setOnClickListener(view -> sharePlainText());
        content.addView(shareButton);

        readinessOutput = new TextView(this);
        readinessOutput.setTextSize(16);
        readinessOutput.setPadding(0, 24, 0, 16);
        content.addView(readinessOutput);

        cardOutput = new TextView(this);
        cardOutput.setTextSize(14);
        cardOutput.setTextColor(Color.rgb(45, 45, 45));
        content.addView(cardOutput);

        setContentView(scrollView);
    }

    private EditText addField(LinearLayout parent, String hint) {
        EditText field = new EditText(this);
        field.setHint(hint);
        field.setSingleLine(true);
        parent.addView(field);
        return field;
    }

    private EditText addMultilineField(LinearLayout parent, String hint) {
        EditText field = new EditText(this);
        field.setHint(hint);
        field.setSingleLine(false);
        field.setMinLines(2);
        field.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_MULTI_LINE);
        parent.addView(field);
        return field;
    }

    private void loadSampleData() {
        dogNameField.setText("Lucky");
        ageField.setText("13 years");
        breedField.setText("Corgi");
        feedingField.setText("Two meals, 80g each. No chicken bones.");
        walksField.setText("Short walk after breakfast, dinner, and before bed.");
        medicationNameField.setText("Pimobendan");
        medicationDoseField.setText("1 tablet");
        medicationTimeField.setText("08:00,20:00");
        missedDoseField.setText("Call the owner before making up a missed dose.");
        ownerPhoneField.setText("TEST-OWNER-PHONE");
        clinicPhoneField.setText("TEST-CLINIC-PHONE");
        caregiverField.setText("Boarding staff");
        buildCard();
    }

    private void buildCard() {
        DogProfile profile = readProfile();
        HandoffDraft draft = new HandoffDraft();
        draft.caregiverName = text(caregiverField);

        HandoffReadinessReport report = HandoffReadiness.evaluate(profile, draft);
        HandoffCardSnapshot snapshot = HandoffCardBuilder.build(profile, draft);
        latestPlainText = snapshot.plainText;

        readinessOutput.setText(formatReadiness(report));
        cardOutput.setText(snapshot.plainText);
        shareButton.setEnabled(!report.hasBlockers());
    }

    private DogProfile readProfile() {
        DogProfile profile = new DogProfile();
        profile.name = text(dogNameField);
        profile.age = text(ageField);
        profile.breed = text(breedField);
        profile.careRule.feeding = text(feedingField);
        profile.careRule.walks = text(walksField);
        profile.careRule.callOwnerIf = "Call owner if medication is refused, appetite changes, vomiting starts, or behavior changes sharply.";
        profile.careRule.goVetIf = "Go to a vet for breathing trouble, seizures, collapse, poisoning risk, bleeding, or ongoing vomiting.";

        if (!HandoffReadiness.isBlank(text(medicationNameField))
            || !HandoffReadiness.isBlank(text(medicationDoseField))
            || !HandoffReadiness.isBlank(text(medicationTimeField))) {
            MedicationItem medication = new MedicationItem();
            medication.name = text(medicationNameField);
            medication.dosage = text(medicationDoseField);
            medication.schedule = text(medicationTimeField);
            medication.missedDoseRule = text(missedDoseField);
            medication.withFood = "Follow owner instruction";
            profile.medications.add(medication);
        }

        EmergencyContact owner = new EmergencyContact();
        owner.role = "Owner";
        owner.name = "Owner";
        owner.phone = text(ownerPhoneField);
        profile.contacts.add(owner);

        EmergencyContact clinic = new EmergencyContact();
        clinic.role = "Clinic";
        clinic.name = "Clinic";
        clinic.phone = text(clinicPhoneField);
        profile.contacts.add(clinic);

        return profile;
    }

    private String formatReadiness(HandoffReadinessReport report) {
        StringBuilder builder = new StringBuilder();
        builder.append("Readiness: ").append(report.score).append(" / 100\n");
        builder.append(report.statusTitle()).append("\n");
        builder.append(report.statusDescription()).append("\n");

        for (HandoffReadinessItem item : report.priorityItems()) {
            builder
                .append("\n- ")
                .append(item.title)
                .append(": ")
                .append(item.detail);
        }
        return builder.toString();
    }

    private void sharePlainText() {
        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.setType("text/plain");
        intent.putExtra(Intent.EXTRA_TEXT, latestPlainText);
        startActivity(Intent.createChooser(intent, "Share handoff card"));
    }

    private String text(EditText field) {
        return field.getText().toString().trim();
    }
}
