function hideTabContent() {
  let tabContent = document.getElementsByClassName("tab");
  for (let tab of tabContent) {
    tab.style.display = "none";
  }
}

function inactivateButtons(){
  buttons = document.querySelectorAll(".tab-bar button");
  for (let button of buttons){
    button.classList.remove("active");
  }
}

function setupTabs() {
  hideTabContent();
  let tabButtons = document.querySelectorAll(".tab-bar>button");
  for (let button of tabButtons) {
    button.addEventListener("click", function (e) {
      hideTabContent();
      let thisTabContent = document.querySelector("#" + button.id + ".tab");
      thisTabContent.style.display = "block";
      inactivateButtons();
      e.currentTarget.classList.add("active");
    })
  }
}

function setup(htmlComponent) {
  // Listen to changes from HTML
  document.getElementById("predictButton").addEventListener("click", function (e) {
    data = { "Input": document.getElementById("userInput").value, "Output": "", "Model": document.querySelector(".modelType:checked").value, "Task": "bert-LM" };
    htmlComponent.Data = data;
  });

  document.getElementById("finbert_submit").addEventListener("click", function (e) {
    data = { "Input": document.getElementById("finbert_input").value, "Task": "finbert-sentiment" };
    htmlComponent.Data = data;
  });

  document.getElementById("gpt2_summary_submit").addEventListener("click", function (e) {
    data = {"Input":document.getElementById("gpt2_summary_input").value, "Task":"gpt2-summarize"};
    htmlComponent.Data = data;
  })

  // Listen for changes from MATLAB
  htmlComponent.addEventListener("DataChanged", function (e) {
    switch (htmlComponent.Data["Task"]) {
      case "bert-LM":
        document.getElementById("outputText").textContent = htmlComponent.Data["Output"];
        tokenOutput = document.getElementById("tokens");
        tokenOutput.innerHTML = "";
        for (let i = 0; i < htmlComponent.Data["Tokens"].length; i++) {
          li = document.createElement("li");
          li.textContent = htmlComponent.Data["Tokens"][i];
          tokenOutput.appendChild(li);
        }
        topkToks = htmlComponent.Data["TopKTokens"];
        topkProbs = htmlComponent.Data["TopKProbs"];
        topkTable = document.getElementById("topktable");
        numMask = htmlComponent.Data["NumMask"];
        // this seems dumb:
        topkTable.innerHTML = "";
        header = document.createElement("tr");
        for (let i = 0; i < numMask; i++) {
          th = document.createElement("th");
          th.textContent = "Token " + (i + 1);
          header.appendChild(th);
        }
        topkTable.appendChild(header);
        for (let i = 0; i < topkToks.length; i++) {
          toks = topkToks[i];
          probs = topkProbs[i];
          tr = document.createElement("tr");
          for (let j = 0; j < numMask; j++) {
            td = document.createElement("td");
            td.textContent = toks[j] + "(" + probs[j] + ")";
            tr.appendChild(td);
          }
          topkTable.appendChild(tr);
        }
        break;
      case "finbert-sentiment":
        outputNode = document.getElementById("finbert_output");
        sentiment = htmlComponent.Data["Output"];
        outputNode.textContent = sentiment;
        outputNode.classList.remove("positive","neutral","negative");
        outputNode.classList.add(sentiment);
        break;
      case "gpt2-summarize":
        outputNode = document.getElementById("gpt2_summary_output");
        summary = htmlComponent.Data["Output"];
        outputNode.textContent = summary;
    }
  });
}

setupTabs();