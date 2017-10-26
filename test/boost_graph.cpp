// Copyright (C) 2017 Tomoyuki Fujimori <moyu@dromozoa.com>
//
// This file is part of dromozoa-graph.
//
// dromozoa-graph is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// dromozoa-graph is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with dromozoa-graph.  If not, see <http://www.gnu.org/licenses/>.

#define BOOST_RECURSIVE_DFS

#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>
#include <boost/graph/adjacency_list.hpp>
#include <boost/graph/breadth_first_search.hpp>
#include <boost/graph/depth_first_search.hpp>
#include <boost/graph/topological_sort.hpp>
#include <boost/graph/undirected_dfs.hpp>
#include <boost/range/iterator_range.hpp>

template <typename G>
inline typename boost::graph_traits<G>::vertex_descriptor add_vertex(G& g, size_t name) {
  const auto result = add_vertex(g);
  boost::put(boost::vertex_name, g, result, name);
  return result;
}

template <typename G, typename V>
inline void add_edge(G& g, V u, V v, size_t name) {
  const auto result = add_edge(u, v, g);
  boost::put(boost::edge_name, g, result.first, name);
}

template <typename G, typename E, typename V>
inline typename boost::graph_traits<G>::vertex_descriptor opposite_vertex(const G& g, E e, V u) {
  const auto v = boost::source(e, g);
  if (u == v) {
    return boost::target(e, g);
  } else {
    return v;
  }
}

template <typename G, typename V>
inline void print_vertex(const char* event, const G& g, V u) {
  const auto uid = boost::get(boost::vertex_name, g, u);
  std::cout << event << "\t" << uid << "\n";
}

template <typename G, typename E>
inline void print_edge(const char* event, const G& g, E e) {
  const auto eid = boost::get(boost::edge_name, g, e);
  std::cout << event << "\t" << eid << "\n";
}

template <typename G, typename E, typename V>
inline void print_edge(const char* event, const G& g, E e, V u) {
  const auto eid = boost::get(boost::edge_name, g, e);
  const auto uid = boost::get(boost::vertex_name, g, u);
  const auto vid = boost::get(boost::vertex_name, g, opposite_vertex(g, e, u));
  std::cout << event << "\t" << eid << "\t" << uid << "\t" << vid << "\n";
}

struct bfs_visitor : boost::bfs_visitor<> {
  template <typename V, typename G>
  void examine_vertex(V u, const G& g) {
    print_vertex("examine_vertex", g, u);
  }

  template <typename E, typename G>
  void examine_edge(E e, const G& g) {
    print_edge("examine_edge", g, e);
  }

  template <typename E, typename G>
  void tree_edge(E e, const G& g) {
    print_edge("tree_edge", g, e);
  }

  template <typename V, typename G>
  void discover_vertex(V u, const G& g) {
    print_vertex("discover_vertex", g, u);
  }

  template <typename E, typename G>
  void non_tree_edge(E e, const G& g) {
    print_edge("non_tree_edge", g, e);
  }

  template <typename E, typename G>
  void gray_target(E e, const G& g) {
    print_edge("gray_target", g, e);
  }

  template <typename E, typename G>
  void black_target(E e, const G& g) {
    print_edge("black_target", g, e);
  }

  template <typename V, typename G>
  void finish_vertex(V u, const G& g) {
    print_vertex("finish_vertex", g, u);
  }
};

struct dfs_visitor : boost::dfs_visitor<> {
  template <typename V, typename G>
  void start_vertex(V u, const G& g) {
    print_vertex("start_vertex", g, u);
  }

  template <typename V, typename G>
  void discover_vertex(V u, const G& g) {
    print_vertex("discover_vertex", g, u);
  }

  template <typename E, typename G>
  void examine_edge(E e, const G& g) {
    print_edge("examine_edge", g, e);
  }

  template <typename E, typename G>
  void tree_edge(E e, const G& g) {
    print_edge("tree_edge", g, e);
  }

  template <typename E, typename G>
  void back_edge(E e, const G& g) {
    print_edge("back_edge", g, e);
  }

  template <typename E, typename G>
  void finish_edge(E e, const G& g) {
    print_edge("finish_edge", g, e);
  }

  template <typename V, typename G>
  void finish_vertex(V u, const G& g) {
    print_vertex("finish_vertex", g, u);
  }
};

template <typename T>
struct selector {
  template <typename G, typename V>
  static void apply(G& g, V) {
    std::cout << "==== tsort ====\n";
    std::vector<V> order;
    boost::topological_sort(g, std::back_inserter(order));
    for (const auto u : order) {
      print_vertex("order", g, u);
    }
  }
};

template <>
struct selector<boost::undirected_tag> {
  template <typename G, typename V>
  static void apply(G& g, V root) {
    std::cout << "==== undirected_dfs ====\n";
    boost::undirected_dfs(g, boost::root_vertex(root).visitor(dfs_visitor()).edge_color_map(boost::get(boost::edge_color, g)));
  }
};

template <typename G>
inline int run(const char* filename) {
  G g;

  std::ifstream in(filename);
  if (!in) {
    std::cerr << "could not open " << filename << std::endl;
    return 1;
  }

  size_t n = 0;
  in >> n;
  if (n == 0) {
    return 1;
  }

  std::vector<typename boost::graph_traits<G>::vertex_descriptor> nodes(n);
  for (size_t i = 0; i < n; ++i) {
    nodes[i] = add_vertex(g, i + 1);
  }

  size_t eid = 0;
  while (in) {
    size_t u = 0;
    size_t v = 0;
    in >> u >> v;
    if (v == 0) {
      break;
    }
    add_edge(g, nodes[u - 1], nodes[v - 1], ++eid);
  }

  const auto root = nodes[0];

  std::cout << "==== each_edge ====\n";
  for (size_t i = 0; i < n; ++i) {
    for (const auto e : boost::make_iterator_range(boost::out_edges(nodes[i], g))) {
      print_edge("each_edge", g, e, nodes[i]);
    }
  }

  std::cout << "==== degree ====\n";
  for (size_t i = 0; i < n; ++i) {
    std::cout << "degree\t" << out_degree(nodes[i], g) << "\n";
  }

  std::cout << "==== bfs ====\n";
  boost::breadth_first_search(g, root, boost::visitor(bfs_visitor()));

  std::cout << "==== dfs ====\n";
  boost::depth_first_search(g, boost::root_vertex(root).visitor(dfs_visitor()));

  selector<typename boost::graph_traits<G>::directed_category>::apply(g, root);

  return 0;
}

template <typename T>
using graph_t = boost::adjacency_list<
  boost::vecS,
  boost::vecS,
  T,
  boost::property<boost::vertex_name_t, size_t>,
  boost::property<boost::edge_name_t, size_t,
    boost::property<boost::edge_color_t, boost::default_color_type>
  >
>;

int main(int argc, char* argv[]) {
  if (argc < 3) {
    return -1;
  }
  std::string directed = argv[1];
  const char* filename = argv[2];
  if (directed == "directed") {
    return run<graph_t<boost::directedS> >(filename);
  } else if (directed == "undirected") {
    return run<graph_t<boost::undirectedS> >(filename);
  }
}
