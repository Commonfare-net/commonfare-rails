var xScale, yScale, zoom, svg, simulation, group, tooltipDiv;

function initSocialGraph()  {
  // All this stuff is for the network viz
  xScale = d3.scaleLinear().domain([0, 1000]).range([0, 1000]);
  yScale = d3.scaleLinear().domain([0, 1000]).range([0, 1000]);

  zoom = d3.zoom().on("zoom", zoomFunction);
  svg = d3.select(".bigvis"), width = +svg.attr("width"), height = +svg.attr("height");
  svg.call(zoom);

  //These forces are tweaked to attract connected nodes to the center
  simulation = d3.forceSimulation()
    .alphaDecay(0.2)
    .force("charge", d3.forceManyBody().strength(function(d){return -300;}))
    .force("link", d3.forceLink().distance(75).iterations(10).id(function(d){return d.id;})) //Need the function here to draw links between nodes based on their ID rather than their index
    .force("x", d3.forceX().x(function(d){if(d.kcore == 0)return 100; return width/2;}).strength(function(d){if(d.kcore == 0)return 0.4; return 0.1;}))
    .force("y", d3.forceY().y(function(d){if(d.kcore == 0)return 100; return height/2;}).strength(function(d){if(d.kcore == 0)return 0.4; return 0.1;}))
    .stop();

  group = svg.append("g").attr("transform", "translate(250,250) scale (.35,.35)"),
  link = group.append("g").attr("stroke", "#000").attr("stroke-width", 1.5).selectAll(".link"),
  node = group.append("g").attr("stroke", "#fff").attr("stroke-width", 1.5).selectAll(".node");
  svg.call(zoom.transform, d3.zoomIdentity.translate(250, 125).scale(0.35));

  // Tooltip functions from http://www.d3noob.org/2013/01/adding-tooltips-to-d3js-graph.html
  tooltipDiv = d3.select("body")
    .append("div")
    .attr("class", "tooltip node-tooltip")
    .style("opacity", 0);
}

// Zooming function
function zoomFunction(){
  var new_xScale = d3.event.transform.rescaleX(xScale)
  var new_yScale = d3.event.transform.rescaleY(yScale)
  group.attr("transform", d3.event.transform)
};

function draw(graph) {
  // console.log(graph);
  node = node.data(graph.nodes,function(d) {return d.id;});
  link = link.data(graph.links,function(d) { return d.source.id + "-" + d.target.id;});

  node.exit().transition()
    .attr("r", 0)
    .remove();

  node = node.enter().append("circle")
    .call(d3.drag()
      .on("start", dragstarted)
      .on("drag", dragged)
      .on("end", dragended)
    )
    .merge(node)
    .attr("id", function(d) { return "n"+d.id; }) //Now each datum can be accessed as a DOM element
    .attr("meta", function(d) { return "n" + JSON.stringify(d.type);})
    .attr("r", function(d) { return (d.kcore*2) + 5;})
    .attr("fill", function(d) {
      if(d.type == "commoner") return d3.color("steelblue");
      if(d.type == "listing") return d3.color("purple");
      if(d.type == "tag") return d3.color("lightgreen");
      return d3.color("red");
    }) // Coloured based on their type

  // Node and link highlighting
  .on("mouseover", function(d) {
    selected_node = d.id;
    d3.select(this).attr("fill",d3.color("orange"));
    sourcelinks = link.filter(function(d){return d.source.id == selected_node || d.target.id == selected_node;});
    //Style links of hovered node
    sourcelinks.each(function(d) {
      d3.select(this).attr("oldstrokeval",d3.select(this).style("stroke-width"));
      var colour = "";
      if(d.edgeweight == null)
          colour = "green";
      else if(d.source.id == selected_node && d.edgeweight[d.source.id] < d.edgeweight[d.target.id])
          colour = "red";
      else if(d.target.id == selected_node && d.edgeweight[d.target.id] < d.edgeweight[d.source.id])
          colour = "red";
      else
          colour = "green";
      d3.select(this).style("stroke",colour);
      d3.select("#mend"+d.source.id + "-" + d.target.id).style("stroke",colour).style("fill",colour);
      d3.select("#mstart"+d.source.id + "-" + d.target.id).style("stroke",colour).style("fill",colour);

    });

    // Add the tooltips, formatted based on whether they represent a user or story
    tooltipDiv.transition()
      .duration(200)
      .style("opacity", .9);
    // NOTE: Uncomment to hide labels on commoner nodes
    // if (d.type == "commoner")
    //   return;
    // NOTE: remove the OR to hide labels on commoner nodes
    if (d.type == "tag" || d.type == "commoner") {
      tooltipDiv.html(d.name)
        .style("left", (d3.event.pageX) + "px")
        .style("top", (d3.event.pageY - 28) + "px")
        .style("background", function() {
          if (d.type == "commoner") return "lightsteelblue";
          return "lightgreen";
        });
    }
    else {
        tooltipDiv.html(d.title)
        .style("left", (d3.event.pageX) + "px")
        .style("top", (d3.event.pageY - 28) + "px")
        .style("background", "pink");
    }
  })
  .on("mouseout", function(d) {
    //Set the colour of links back to black, and the thickness to its original value
    d3.select(this).attr("fill", function(d) {
      if(d.type == "commoner") return d3.color("steelblue");
      if(d.type == "listing") return d3.color("purple");
      if(d.type=="tag") return d3.color("lightgreen");
      return d3.color("red");
    });
    sourcelinks.each(function(d) {
      d3.select(this).style("stroke","black");
    });
    sourcelinks.each(function(d) {
      d3.select(this).style("stroke-width", d3.select(this).attr("oldstrokeval"));
      d3.select("#mstart" + d.source.id + "-" + d.target.id).style("stroke", "black").style("fill", "black");
      d3.select("#mend" + d.source.id + "-" + d.target.id).style("stroke", "black").style("fill", "black");
    });
    tooltipDiv.transition()
      .duration(500)
      .style("opacity", 0);
  });

   //  Arrowheads that show the direction of the interaction. Have to be drawn manually
  svg.selectAll("defs").remove();
  svg.append("defs").selectAll("marker")
    .data(graph.links)
    .enter().append("marker")
    .attr("id", function(d) { return "mend" + d.source.id + "-" + d.target.id; })
    .attr("viewBox", "0 -5 10 10")
    .attr("refX", function(d) {
      if(d.target.id == null) return 10;
      radius = d3.select("#n"+d.target.id).attr("r");
      return 10 + parseInt(radius);
    })
    .attr("markerUnits","userSpaceOnUse")
    .attr("markerWidth", 10)
    .attr("markerHeight", 10)
    .attr("orient", "auto")
    .append("path")
    .attr("d", "M0,-5L10,0L0,5");

  svg.append("defs").selectAll("marker")
    .data(graph.links)
    .enter().append("marker")
    .attr("id", function(d) { return "mstart" + d.source.id + "-" + d.target.id; })
    .attr("viewBox", "-10 -5 10 10")
    .attr("refX", function(d) {
      if(d.source.id == null)return 10;
      radius = d3.select("#n"+d.source.id).attr("r");
      return -10 - parseInt(radius);
    })
    .attr("markerUnits","userSpaceOnUse")
    .attr("markerWidth", 10)
    .attr("markerHeight", 10)
    .attr("orient", "auto")
    .append("path")
    .attr("d", "M0,-5L-10,0L0,5");

  // Add the links. Thickness is currently determined by the square root of the sum of the weight from either node
  link.exit()
    .remove();
  link = link.enter().append("line")
    .attr("class","line")
    .merge(link)
    .attr("stroke-width",1.5)
    .attr("edgemeta", function(d) {
      return d.id + JSON.stringify(d.edgemeta);
    })
    .attr("marker-end", function(d){
      if (d.source.type == 'commoner') return "url(#mend" + d.source.id + "-" + d.target.id + ")";
      return null;
    })
    .attr("marker-start", function(d){
      if(d.target.type == 'commoner') return "url(#mstart" + d.source.id + "-" + d.target.id + ")";
      return null;
    })
    .style("stroke","green");

  // Updates to make on simulation 'tick'
  function ticked() {
    link
    .attr("x1", function(d) { return d.source.x; })
    .attr("y1", function(d) { return d.source.y; })
    .attr("x2", function(d) { return d.target.x; })
    .attr("y2", function(d) { return d.target.y; });

    node
    .attr("cx", function(d) { return d.x; })
    .attr("cy", function(d) { return d.y; });
  }

  // Dragging functions
  function dragstarted(d) {
    d3.event.sourceEvent.stopPropagation();
    d.fx = d.x;
    d.fy = d.y;
  }

  function dragged(d) {
    d.fx = d3.event.x;
    d.fy = d3.event.y;
    d.x = d3.event.x;
    d.y = d3.event.y;
    ticked();
  }

  function dragended(d) {
    d.fx = null;
    d.fy = null;
  }

  d3.timeout(function() {
    // Update and restart the simulation.
    simulation.nodes(graph.nodes);
    //Manually update the simulation so it doesn't take a long time to do its thing
    simulation.force("link").links(graph.links);
    simulation.alpha(1);
    for (var i = 0, n = Math.ceil(Math.log(simulation.alphaMin()) / Math.log(1 - simulation.alphaDecay())); i < n; ++i) {
      simulation.tick();
    }
    link.attr("x1", function(d) { return d.source.x; })
    .attr("y1", function(d) { return d.source.y; })
    .attr("x2", function(d) { return d.target.x; })
    .attr("y2", function(d) { return d.target.y; });

    node.attr("cx", function(d) { return d.x; })
    .attr("cy", function(d) { return d.y; });
    //If we've clicked on a node, maintain its focus while going through the different months
  });
}
